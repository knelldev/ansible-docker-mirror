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
the bridge; `proxmox_vm_info` lists guests. Version floor `>=2.0.0` (the
version whose source was read).

Download (task 1.2, checked in the 2.0.0 source,
[proxmox_template.py](https://github.com/ansible-collections/community.proxmox/blob/main/plugins/modules/proxmox_template.py)):
`url` calls `POST /nodes/{node}/storage/{storage}/download-url`, so the node
downloads, not the controller. With only `template` (no `url`/`src`) the
module calls `POST /nodes/{node}/aplinfo`, the `pveam` path, which fetches
from the Proxmox appliance index. The role uses the `aplinfo` path: it reads
`GET /nodes/{node}/aplinfo` (read-only, `ansible.builtin.uri`), picks the
newest name matching `almalinux-10-default_*_amd64.tar.xz` and passes it as
`template`. The module skips the download when the file already exists.
Clones and renames always pass an explicit VMID from `GET /cluster/nextid`,
because the module looks guests up by name and the old and new templates
share a name. Guest IP: `GET /nodes/{node}/lxc/{vmid}/interfaces`.

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
variables, not a CT-only role. No `lxc_base`, no separate `os_base`: every
host that gets the base also gets `os_prepare`, so the new parts are switchable
task files in `os_prepare`.

| Role | Runs on | Does | Switches and values |
|---|---|---|---|
| `os_prepare` (extended) | any EL host | as today, plus admin user, first-boot identity unit, node_exporter, weekly full-update window | `os_prepare_admin_enabled` (default off, so re-running on existing hosts changes nothing), `os_prepare_admin_user` (default `localadmin`), `os_prepare_admin_pubkeys`; `os_prepare_firstboot_enabled`, `os_prepare_node_exporter_enabled`, `os_prepare_weekly_update_enabled` (default on, CT-Q6), `os_prepare_weekly_update_oncalendar` (`Thu 04:00`), `os_prepare_weekly_update_reboot` (default `never`; template `when-needed`); `os_prepare_dnf_automatic_upgrade_type` (default `default`), `os_prepare_dnf_automatic_apply_updates` (default off: download only; template on) |
| `os_container` (changed) | hosts that run Podman | as today | new `os_container_subid_min`/`_max` (default unset = OS defaults); `os_container_default_netns` (default unset = Podman's default); `os_container_unprivileged_port_start` (default unset = kernel default 1024); SELinux guard |
| `os_template_reset` (new) | only a guest about to become a template (CT now, VM template later) | removes identity, keys, logs, caches; own role so it never runs on a live host by accident | `os_template_reset_remove_paths`, `os_template_reset_remove_root_keys` |
| `pve_ct_template` (new) | localhost, Proxmox API | download, build CT, template, int clone, test, swap | node, bridges, template names, pool, storages, sizes, cores, memory, features: all variables, defaults = the decisions in `lab_01_migrations` |

No sshd or firewall changes (user, 2026-10-18): RHEL defaults stay
(`PermitRootLogin prohibit-password`, crypto policy DEFAULT; not checked on
the Alma 10 image); root has no password or key after the reset, `localadmin`
has a locked password. Password/keyboard-interactive SSH may matter for the
authentik agent trial; close it only if the trial shows a need. firewalld is
left as the image ships it; filtering is the Proxmox firewall's job. If the
image has firewalld active, the clone test (node_exporter on 9100) shows it.

### Baseline order (inside the build CT, as root with the build key)

`playbooks/pve_ct_template.yml` sets the CT values in one vars block:

1. `os_prepare` with `os_prepare_admin_enabled: true`,
   `os_prepare_packages` without `qemu-guest-agent`,
   `os_prepare_dnf_automatic_upgrade_type: security`; also creates group
   `data` (it sets `/data` to `root:data` but creates no group today).
2. `os_container` with `os_container_auto_update_schedule` Thu 04:30,
   `os_container_subid_min: 10000`, `_max: 65533`,
   `os_container_default_netns: host` and
   `os_container_unprivileged_port_start: 80`. Graphroot
   `/data/containers/storage` lands on `mp0`.
3. `os_template_reset` as the last step.

### Rootless Podman network (user, 2026-10-18)

Rootless Podman uses the host network (the CT's own network namespace).
Reason: pasta and slirp4netns both need `/dev/net/tun`; an unprivileged
Proxmox CT has none, and only `root@pam` can add it (`dev0`). The user wants
no root login for anyone, including automation.

- `os_container_default_netns` (default unset: no file, Podman's default)
  writes `/etc/containers/containers.conf.d/50-netns.conf` with
  `[containers]` `netns = "<value>"`. containers.conf(5) lists
  `/etc/containers/containers.conf.d` as a drop-in directory for all users,
  next to the rootless-only `containers.rootless.conf.d/$UID`, and documents
  `netns` with the same values as `--network`, including `host`
  ([containers.conf.5.md](https://github.com/containers/container-libs/blob/main/common/docs/containers.conf.5.md),
  checked 2026-10-18). The template sets `host`.
- `os_container_unprivileged_port_start` (default unset: no file) writes
  `/etc/sysctl.d/50-unprivileged-port-start.conf`. The template sets `80`:
  on the host network a rootless service cannot use Podman port mapping, so a
  web app must bind 80/443 itself; ports below 80 (SSH 22, DNS 53) stay
  privileged. The sysctl is per network namespace; whether an unprivileged CT
  may set it is to verify in an unprivileged CT (clone test, task 2.2).
- Services bind `127.0.0.1` (callers in the same CT) or the CT IP, filtered
  by the Proxmox firewall (`firewall=1` on `net0`). `-p` port publishing has
  no effect on the host network.

Alternatives rejected (all need root): seed CT with `/dev/net/tun` added by
`root@pam`; a node-wide `/usr/share/lxc/config/common.conf.d` device entry;
an automation login as `root@pam`.

### Secrets (CT-Q1/CT-Q2, user, 2026-10-18)

The Proxmox API host, user, token id and token secret, the build key pair
and the `localadmin` keys are role variables whose defaults are
`lookup('ansible.builtin.env', ...)` (`PROXMOX_HOST`, `PROXMOX_USER`,
`PROXMOX_TOKEN_ID`, `PROXMOX_TOKEN_SECRET`, `PVE_CT_TEMPLATE_BUILD_PUBKEY`,
`PVE_CT_TEMPLATE_BUILD_KEY_FILE`, `PVE_CT_TEMPLATE_ADMIN_PUBKEYS`,
`PVE_CT_TEMPLATE_ADMIN_KEY_FILE`). Semaphore sets them now (environment and
key store); Bitwarden Secrets Manager can feed the same variables later
without code changes. One Semaphore task builds both templates.

### Package diff in the notes (CT-Q4, CT-Q5, user 2026-10-18)

The notes hold two diffs (lines new or changed, `name-version-release`):
against the stock image (package list before the baseline) and against the
previous template (CT-Q5: "both"). Full lists go to the task log.

The previous list lives in the previous template's own notes, so no extra
rights, storage or secrets: each build writes its full package list as the
last notes line `pkglist.gz.b64: <gzip | base64>` (made and unpacked in the
build CT with `gzip`/`base64`). The next build reads it from the recorded
old `ct-alma-10-dmz` VMID (`GET /nodes/{node}/lxc/{vmid}/config`, same
token).

Size: pve-container limits an LXC description to `maxLength => 1024 * 8`
(8192) characters
([src/PVE/LXC/Config.pm](https://git.proxmox.com/?p=pve-container.git;a=blob;f=src/PVE/LXC/Config.pm;hb=7cc33f73778067a4b0deaf4443d8b4b2273afe36),
checked 2026-10-18). Measured in an AlmaLinux 10 container (aarch64, local
Docker, systemd/openssh/NetworkManager added, then the baseline packages
incl. podman and node-exporter): 296 packages, 8191 bytes raw, 3876
characters gzip+base64 (13.1 per package). Estimate for 450 packages: about
5900. The role caps the notes at 8000 and keeps at least 1500 for the text:
the list is stored while it is at most about 6500 characters (about 490
packages at the measured rate). The text is cut to the rest. Fallback: if
the list does not fit or cannot be made, the notes say so and the next build
shows only the stock diff; a build without a stored previous list writes
"no stored package list" instead of that diff. The first build after this
change has no previous list.

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
- `os_container`: subid range writes `SUB_UID_MIN/MAX/COUNT`,
  `SUB_GID_MIN/MAX/COUNT` in `/etc/login.defs` only when the variables are
  set. `COUNT` is `max - min + 1` (55534 for the template), because
  `useradd`'s default count of 65536 does not fit in the range.
- `os_prepare`: `dnf-automatic.conf.j2` had `reboot = no-reboot` under
  `[upgrade]`, which dnf 4 does not read (its `reboot` option lives in
  `[commands]`). The template now writes `reboot` in `[commands]` from
  `os_prepare_dnf_automatic_reboot`, default `never`, the same effective
  behavior as before.
- `os_prepare`: creates group `data` before `/data` gets `root:data`.
- `os_prepare`: the same template also had `download_updates` and
  `apply_updates` under `[download]`/`[base]`; dnf 4 reads them in
  `[commands]`, where they now are. Hosts that ran `os_prepare` with
  `dnf-automatic.timer` start applying updates as the file always intended
  (before, dnf 4 used its documented default `apply_updates = False`,
  [dnf automatic docs](https://dnf.readthedocs.io/en/latest/automatic.html);
  not checked on a host). `apply_updates` is now a variable
  (`os_prepare_dnf_automatic_apply_updates`, default `no`), so the daily run
  on existing hosts keeps downloading only.
- `os_prepare` defaults for existing hosts (CT-Q6, user 2026-10-18: "weekly
  after backup just to be sure"): daily download only; weekly full update on
  (`os_prepare_weekly_update_enabled: true`, Thu 04:00, after the Thu 02:00
  PBS backup) with `os_prepare_weekly_update_reboot: never`, so a re-run
  causes no surprise reboots. The template playbook keeps its own values
  (daily security applied, weekly `when-needed`). Hosts outside the
  backed-up PBS pools (DMZ, CORE, INT) get the weekly update without a
  fresh backup.
- `os_prepare` has no SELinux or firewall tasks. `30-customize.yml` runs an
  `echo`; left as is. New parts go in their own numbered task files, each
  behind its switch.

### New `os_prepare` parts

- Admin user (`localadmin`, user, 2026-10-18): SSH key only, locked
  password, sudo `NOPASSWD`, used by automation and as fallback when
  authentik is down. No hardening step; authentik agent out of scope.
- First boot: `firstboot-identity.service`, `Before=sshd.service`, runs once
  per clone (marker `/var/lib/firstboot-identity.done`): new machine-id,
  `ssh-keygen -A`. Reason: Proxmox keeps the template's host keys and writes
  only `\n` to `/etc/machine-id` on clone (user's finding). EL's
  `sshd-keygen` and systemd first boot overlap partly; the unit makes it
  explicit.
- node_exporter with `--collector.systemd`. Source (task 1.4): EPEL 10
  package `node-exporter` (1.12.1 in EPEL 10.4; ships
  `/usr/bin/node_exporter`, units `node_exporter.service` and
  `prometheus-node-exporter.service`;
  [packages.fedoraproject.org](https://packages.fedoraproject.org/pkgs/node-exporter/node-exporter/epel-10.4.html),
  checked 2026-10-18). Chosen over an upstream binary: updates come with
  dnf-automatic. The flag is set by a systemd drop-in that replaces
  `ExecStart` on `node_exporter.service`; how the two shipped units relate
  (alias or separate) is [unverified], the clone test checks the systemd
  metrics.
- Updates: daily security via `os_prepare`'s dnf-automatic. Weekly full update
  as a second dnf-automatic unit with its own config (`upgrade_type =
  default`, `reboot = when-needed`), timer Thu 04:00, after the Thu 02:00 PBS
  backup. Podman auto-update Thu 04:30. Check (task 1.4): AlmaLinux 10 ships
  dnf 4.20 with `dnf-automatic`, not dnf5
  ([git.almalinux.org rpms/dnf a10s](https://git.almalinux.org/rpms/dnf/src/branch/a10s));
  dnf 4 documents `reboot = never|when-changed|when-needed` in `[commands]`
  ([dnf automatic docs](https://dnf.readthedocs.io/en/latest/automatic.html)).
  The release that added the option was not checked [unverified]; the live
  build shows a config error if 4.20 lacks it. In a CT no kernel updates
  apply, so `when-needed` reboots only for systemd/glibc-type updates.

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

### Failure handling across plays

The playbook has five plays (API, build CT, API, test clone, API). Each
play's work sits in a `block` with a `rescue` that records the failure as a
fact instead of failing the host, because Ansible stops the whole run when
every host of a play fails, and the cleanup play must still run. The last
play destroys what the run created on any failure and then fails the run.
If a guest becomes unreachable mid-run (not caught by `rescue`), the run
stops; the next run removes leftover `ct-build-*`/`ct-test-*` guests and,
after its own test passes, every older `ct-alma-10-*` template it recorded.

## Risks / Trade-offs

- During the swap window two templates share a name.
- Semaphore must reach DHCP addresses on `vmbr1` (CT-Q3: allowed int→DMZ).
- Rootless Podman on the host network: containers in one CT share its
  network; no per-container isolation. Fine for one app per CT.
- Last-resort fallback if rootless Podman on the host network fails in the
  clone test: rootful Podman in the CT (no `/dev/net/tun` needed with
  netavark bridge [unverified]); only after a user decision.
- The subid range gives 55534 IDs: images that use IDs above that inside the
  container (for example `nobody` 65534) fail to map.
- `net.ipv4.ip_unprivileged_port_start` may be read-only in an unprivileged
  CT [unverified]; then the sysctl task fails in the build and the value has
  to go.

## Open Questions

- CT-Q1 (Semaphore layout): resolved (user, 2026-10-18): environment
  variables set by Semaphore, one task for both templates; see Secrets.
- CT-Q2 (key location): resolved (user, 2026-10-18): Semaphore now,
  Bitwarden Secrets Manager later through the same variables.
- CT-Q3 (reachability): resolved (user: simplest, 2026-10-18): DHCP, guest IP
  from the Proxmox API; int→DMZ is allowed.
- CT-Q4 (package diff source): resolved (user: simplest, 2026-10-18): only
  the diff in the notes, full list in the task log.
- CT-Q5 (diff baseline): resolved (user, 2026-10-18: "both"): diff against
  the stock image and against the previous template, whose list is stored
  compressed in its own notes; see Package diff.
- CT-Q6 (dnf-automatic fix on existing hosts): resolved (user, 2026-10-18):
  daily download only, weekly full update after the backup without reboot;
  see Changes to existing roles.
