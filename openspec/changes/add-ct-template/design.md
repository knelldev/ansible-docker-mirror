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

### Role split (user, 2026-10-18: flexible, configured by variables)

Every role works on any EL host; what makes a CT template is the playbook's
variables, not a CT-only role. No `lxc_base`.

| Role | Runs on | Does | Switches and values |
|---|---|---|---|
| `os_base` (new) | any EL host: CT, VM, bare metal | local admin, sshd hardening, first-boot identity unit, node_exporter, weekly full-update window | `os_base_admin_enabled`, `os_base_admin_user` (default `localadmin`), `os_base_admin_pubkeys`; `os_base_sshd_enabled`; `os_base_firstboot_enabled`; `os_base_node_exporter_enabled`, `os_base_node_exporter_collectors`; `os_base_weekly_update_enabled`, `os_base_weekly_update_oncalendar` (default `Thu 04:00`), `os_base_weekly_update_reboot` (default `when-needed`) |
| `os_prepare` (changed) | as today | packages, dnf-automatic | new `os_prepare_dnf_automatic_upgrade_type` (default `default`); packages list already a variable |
| `os_container` (changed) | as today | Podman, graphroot, auto-update | new `os_container_subid_min`/`_max` (default unset = OS defaults); SELinux guard |
| `os_template_reset` (new) | any guest about to become a template (CT now, VM template later) | removes identity, keys, logs, caches | `os_template_reset_remove_paths`, `os_template_reset_remove_root_keys` (list); defaults cover the list below |
| `pve_ct_template` (new) | localhost, Proxmox API | download, build CT, template, int clone, test, swap | node, bridges, template names, pool, storages, sizes, cores, memory, features: all variables, defaults = the decisions in `lab_01_migrations` |

Defaults are on for each `os_base` part; existing hosts are unaffected
because no current playbook includes `os_base` or `os_template_reset`.
A VM later uses the same roles with different values (e.g. keep
`qemu-guest-agent`, no subid range).

### Baseline order (inside the build CT, as root with the build key)

`playbooks/pve_ct_template.yml` sets the CT values in one vars block:

1. `os_base`: `localadmin`, sshd, first-boot unit, node_exporter, weekly
   window; also creates group `data` (needed by `os_prepare`, which sets
   `/data` to `root:data` but creates no group).
2. `os_prepare` with `os_prepare_packages` without `qemu-guest-agent` and
   `os_prepare_dnf_automatic_upgrade_type: security`.
3. `os_container` with `os_container_auto_update_schedule` Thu 04:30 and
   `os_container_subid_min: 10000`, `_max: 65533`. Graphroot
   `/data/containers/storage` lands on `mp0`.
4. `os_template_reset` as the last step.

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
- `os_container`: subid range writes `SUB_UID_MIN/MAX`, `SUB_GID_MIN/MAX` in
  `/etc/login.defs` only when the variables are set.
- `os_prepare` has no SELinux tasks. `30-customize.yml` runs an `echo`; left
  as is.

### `os_base` contents

- Admin user (`localadmin`): SSH key only, locked password, sudo `NOPASSWD`,
  used by automation and as fallback when authentik is down.
- sshd drop-in: `PermitRootLogin no`, `PasswordAuthentication no`.
- First boot: `firstboot-identity.service`, `Before=sshd.service`, runs once
  per clone (marker `/var/lib/firstboot-identity.done`): new machine-id,
  `ssh-keygen -A`. Reason: Proxmox keeps the template's host keys and writes
  only `\n` to `/etc/machine-id` on clone (user's finding). EL's
  `sshd-keygen` and systemd first boot overlap partly; the unit makes it
  explicit.
- node_exporter with `--collector.systemd`. Source (EPEL package for EL10 or
  pinned upstream binary) is not verified yet; task 1.4 decides.
- Updates: daily security via `os_prepare`'s dnf-automatic. Weekly full update
  as a second dnf-automatic unit with its own config (`upgrade_type =
  default`, `reboot = when-needed`), timer Thu 04:00, after the Thu 02:00 PBS
  backup. Podman auto-update Thu 04:30. Whether `reboot = when-needed` works
  with the dnf version in Alma 10 is to be checked in 1.4.

### `os_template_reset` contents

Remove build key from root, SSH host keys, first-boot marker; truncate
`/etc/machine-id`; remove NetworkManager connection files and `/etc/hostname`
(Proxmox rewrites them on start); clear logs and journal, dnf cache, shell
histories, `/tmp`, `/var/tmp`.

### App users and the rootless contract

The template has no app user. `define-rootless-podman-user-contract`
(inactive) puts the service user in the consuming role, which fits. Today's
`con_*` roles run rootful Quadlets and create no user, so nothing conflicts
yet. The gap: the contract says nothing about subuid/subgid. Default
`useradd` ranges start at 100000, outside the CT's map, so rootless Podman
would fail. Decided (user, 2026-10-18): one app user per CT with the full
range 10000–65533 (below `nobody` 65534); the contract should reference it.

### Clone test

Clone `ct-alma-10-dmz` to `ct-test-alma-10`, start, connect as `localadmin`, check:
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
  the Proxmox token, build key and `localadmin` key; one Semaphore task or one per
  template?
- CT-Q2 (key location): where the build and `localadmin` key pairs live (Vaultwarden,
  Semaphore key store, ansible-vault in an inventory repo), and who rotates
  them.
- CT-Q3 (reachability): can the Semaphore runner reach DHCP addresses on
  `vmbr1` (DMZ) over SSH, or does the build need a fixed IP or a jump host?
- CT-Q4 (package diff source): store the previous package list in the template
  notes (size limit) or elsewhere?
