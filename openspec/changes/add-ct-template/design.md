## Context

- Contracts: `TECHSTACK.md` (role skeleton, FQCN, collections need a version
  floor), `roles/AGENTS.md` (numbered tasks, role-prefixed variables).
- Source of the decisions: `lab_01_migrations`, change `idm` (template names,
  pool `Templates`, pve3 without `vmbr1`).
- Related plan: `define-rootless-podman-user-contract` (inactive).
- Not verified on a live system: everything Proxmox-side below is from the
  user and the docs, not from a test run.

## Decisions

### Collection and API calls

`community.proxmox` (docs checked 2026-10-18, collection 2.0.0): `proxmox`
handles LXC create, clone (`clone_type: full`), start/stop, `state: template`,
`mount_volumes`, `features`, `pool`, `description`, `pubkey`;
`proxmox_tasks_info` lists running tasks; `proxmox_node_network_info` checks
the bridge. `proxmox_template` has a `url` parameter, but the docs do not say
whether the node downloads it (`download-url`) or the controller does. If it
is the controller, use `ansible.builtin.uri` against
`POST /nodes/{node}/storage/pve-z2/download-url` with the checksum from
`GET /nodes/{node}/aplinfo`. Guest IP: `GET /nodes/{node}/lxc/{vmid}/interfaces`.

### Guest guard

Every destroy, stop or convert call goes through one check: name starts with
`ct-`, type is `lxc`, and the VMID is one the run created or recorded at the
start. Build CT `ct-build-alma-10`, test clone `ct-test-alma-10`. A leftover
`ct-build-*` or `ct-test-*` from a failed run is removed at the start.

### Swap

At the start the run records the VMIDs of the current `ct-alma-10-dmz` and
`ct-alma-10-int`. New templates get the same names, so both exist for a short
window; consumers pick the highest VMID. After a passed test the recorded old
VMIDs are destroyed, unless `proxmox_tasks_info` shows a running clone from
them; then they stay and the next run removes them. On any failure a `rescue`
destroys only the VMIDs created in this run.

### Node

Variable, default `pve`, allowed `pve`/`pve2`. The role asserts that `vmbr1`
exists on the node before creating anything (pve3 has none).

### Baseline order (inside the build CT, as root with the build key)

1. `lxc_base` pre-tasks: group `data` (needed by `os_prepare`, which sets
   `/data` to `root:data` but creates no group), `ops` user, sshd.
2. `os_prepare` with `os_prepare_packages` overridden without
   `qemu-guest-agent`, and `os_prepare_dnf_automatic_upgrade_type: security`.
3. `os_container` with `os_container_auto_update_schedule` set into the
   Thursday window. Graphroot `/data/containers/storage` lands on `mp0`.
4. `lxc_base` rest: node_exporter, weekly updates, first-boot unit, subuid
   range, then the reset as the last step.

### Changes to existing roles

- `os_prepare`: `templates/dnf-automatic.conf.j2` hardcodes
  `upgrade_type = default` (all updates daily). Add
  `os_prepare_dnf_automatic_upgrade_type`, default `default`, so existing
  hosts keep their behavior.
- `os_container`, `tasks/10-install.yml`: the tasks "Apply SELinux context
  recursively to Podman storage 1/2" (`semanage fcontext`) and "2/2"
  (`restorecon`) get `when: graphroot_lineinfile.changed and
  ansible_selinux.status | default('disabled') == 'enabled'`. Chosen over
  `ansible_virtualization_type == 'lxc'` because it states the real
  precondition and also covers other hosts without SELinux.
- `os_prepare` has no SELinux tasks. `30-customize.yml` runs an `echo`; left
  as is.

### `lxc_base` contents

- `ops`: SSH key only, locked password, sudo `NOPASSWD`, used by automation
  and as fallback when authentik is down.
- sshd drop-in: `PermitRootLogin no`, `PasswordAuthentication no`.
- First boot: `ct-firstboot.service`, `Before=sshd.service`, runs once per
  clone (marker `/var/lib/ct-firstboot.done`): new machine-id, `ssh-keygen
  -A`. Reason: Proxmox keeps the template's host keys and writes only `\n` to
  `/etc/machine-id` on clone (user's finding). EL's `sshd-keygen` and systemd
  first boot overlap partly; the unit makes it explicit.
- node_exporter with `--collector.systemd`. Source (EPEL package for EL10 or
  pinned upstream binary) is not verified yet; task 1.4 decides.
- Updates: daily security via `os_prepare`'s dnf-automatic. Weekly full update
  as a second dnf-automatic unit with its own config (`upgrade_type =
  default`, `reboot = when-needed`), timer Thu 04:00, after the Thu 02:00 PBS
  backup. Podman auto-update Thu 04:30. Whether `reboot = when-needed` works
  with the dnf version in Alma 10 is to be checked in 1.4.
- Subordinate IDs: `/etc/login.defs` `SUB_UID_MIN/MAX`, `SUB_GID_MIN/MAX`
  inside the CT's 65536-ID map (see app users below).
- Reset, last step: remove build key from root, SSH host keys, firstboot
  marker; truncate `/etc/machine-id`; remove NetworkManager connection files
  and `/etc/hostname` (Proxmox rewrites them on start); clear logs and
  journal, dnf cache, shell histories, `/tmp`, `/var/tmp`.

### App users and the rootless contract

The template has no app user. `define-rootless-podman-user-contract`
(inactive) puts the service user in the consuming role, which fits. Today's
`con_*` roles run rootful Quadlets and create no user, so nothing conflicts
yet. The gap: the contract says nothing about subuid/subgid. Default
`useradd` ranges start at 100000, outside the CT's map, so rootless Podman
would fail. The template sets the range (proposal: 10000–65533, below
`nobody` 65534) and a per-user count; the contract should reference it.

### Clone test

Clone `ct-alma-10-dmz` to `ct-test-alma-10`, start, connect as `ops`, check:
host keys and machine-id differ from the build CT's recorded values, default
route and DNS lookup work, `sshd` active, a throwaway user runs
`podman run --rm` of a small image, `node_exporter` answers on 9100. Only the
dmz template is tested; int differs only in the bridge.

## Risks / Trade-offs

- Proxmox description size limits the package list in notes; the diff source
  is an open question.
- During the swap window two templates share a name.
- Semaphore must reach DHCP addresses on `vmbr1`.

## Open Questions

- CT-Q1 (Semaphore layout): which inventory, environment and key store hold
  the Proxmox token, build key and `ops` key; one Semaphore task or one per
  template?
- CT-Q2 (key location): where the build and `ops` key pairs live (Vaultwarden,
  Semaphore key store, ansible-vault in an inventory repo), and who rotates
  them.
- CT-Q3 (reachability): can the Semaphore runner reach DHCP addresses on
  `vmbr1` (DMZ) over SSH, or does the build need a fixed IP or a jump host?
- CT-Q4 (package diff source): store the previous package list in the template
  notes (size limit) or elsewhere?
- CT-Q5 (subuid size): per-app count. 10000 IDs allow about five apps per CT
  but break images that use IDs above 10000 (e.g. `nobody` 65534).
