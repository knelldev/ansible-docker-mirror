## Why

New homelab services run in Proxmox LXC containers (migration repo
`lab_01_migrations`, change `idm`). Each container needs the same AlmaLinux 10
baseline: admin access, updates, Podman and node_exporter.
Building that by hand drifts and goes stale. A scheduled build keeps two
current templates and replaces them only after a test clone passes.

## What Changes

- Add `roles/pve_ct_template/` and `playbooks/pve_ct_template.yml`. It runs on
  localhost against the Proxmox API (token `automation@pve!lxc-template`) and:
  - downloads the stock `almalinux-10-default_*_amd64.tar.xz` to `pve-z2`
    through the node (API `download-url`);
  - creates an unprivileged build CT (`nesting=1` only, 2 cores, 2048 MB,
    rootfs 15G + `mp0` 35G at `/data` on `pve-ssd`, `net0` on `vmbr1` with
    `firewall=1,ip=dhcp`, root key = build key) on node `pve` or `pve2`;
  - starts it, waits for SSH, runs the baseline, resets it, stops it;
  - converts it to template `ct-alma-10-dmz` in pool `Templates` with notes
    (Alma minor version, git commit, package diff against the
    stock image; CT-Q5 in `design.md`);
  - full-clones it to `ct-alma-10-int` on `vmbr0` and converts that too;
  - tests a clone of the new template, then destroys the test clone;
  - on failure deletes the new templates and keeps the old ones; on success
    deletes the previous templates unless a clone task from them is running.
- Extend `roles/os_prepare/` with switchable parts (any EL host): local admin
  `localadmin` (default off), a first-boot identity unit, node_exporter, the
  weekly update window. No sshd or firewall changes.
- Add `roles/os_template_reset/` (any guest before templating, VM template
  later): the reset before templating.
- All CT-specific values (sizes, bridges, names, subid range, packages) live
  in the playbook's variables, not in a CT-only role.
- Reuse `os_prepare` and `os_container` in the baseline, with two small
  changes: a variable for the dnf-automatic upgrade type (`os_prepare`), an
  SELinux guard on the two `semanage`/`restorecon` tasks, optional subid
  range variables, an optional default network namespace for all Podman
  users and an optional `net.ipv4.ip_unprivileged_port_start` (`os_container`).
  The template sets rootless Podman to the host network: an unprivileged CT
  has no `/dev/net/tun`, which pasta and slirp4netns need, and only `root@pam`
  could add it.
- Schedule the playbook in Semaphore every ~3 weeks.
- Dependency: enable `community.proxmox` in `collections/requirements.yml`
  (today commented out) with a version floor, and record it in `TECHSTACK.md`.

## Capabilities

### New Capabilities

- `ct-template-build`: scheduled, tested build and replacement of the LXC
  templates.
- `ct-baseline`: baseline and reset of an AlmaLinux 10 guest for templating.

### Modified Capabilities

- None (no accepted spec covers `os_prepare` or `os_container`).

## Impact

- New roles, playbook, role README/AGENTS, `roles/AGENTS.md` index, root
  README playbook list, `TECHSTACK.md` collection row.
- `os_prepare`: new switchable parts and variables; defaults keep re-runs on
  existing hosts safe (admin user off).
- `os_container`: SELinux tasks skip where SELinux is not enabled; subid
  range only when set.
- External: Proxmox API (token and key paths read from environment
  variables, set by Semaphore now, swappable for Bitwarden Secrets Manager), `download.proxmox.com`
  (fetched by the node), EPEL/Alma mirrors, Semaphore schedule.

## Scope Boundary And Exclusions

- No app user in the template; `con_*` roles own app users.
- Later, not here: authentik agent install and enrollment (decided after a
  trial), monitoring scrape config, the per-clone enrollment job, firewall
  rules for node_exporter.
- No VM templates; the role never touches guests whose name does not start
  with `ct-` (the token can also reach VM templates 10000/10001/130 in pool
  `Templates`).
- No migration of `pve_vm_clone` from `community.general` to
  `community.proxmox`.
- No live run in this change until the user approves it per step.

## Alternatives And Risks

- Build in a VM with Packer, or customise the tarball offline: no API-driven
  CT lifecycle, but no tested Proxmox-side result either. Rejected.
- Linked instead of full clone for `ct-alma-10-int`: depends on the dmz
  template staying, which blocks replacing it. Rejected.
- Risk: a bug in the cleanup deletes the wrong guest. Mitigation: name prefix
  `ct-`, type `lxc` and recorded VMID checks before every destroy.
- Risk: rootless Podman on the host network has no network isolation
  between containers of one CT; acceptable with one app per CT. Rootful
  Podman is the last-resort fallback only (`design.md`, Risks).
- Risk: the token secret and the build/localadmin private keys live in Semaphore.

Approval status: scope decided with the user on 2026-10-18 (session in
`lab_01_migrations`); approved for implementation on 2026-10-18 (user,
herdr-inbox Q3). Live runs still need approval per step.
