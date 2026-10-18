## Why

New homelab services run in Proxmox LXC containers (migration repo
`lab_01_migrations`, change `idm`). Each container needs the same AlmaLinux 10
baseline: admin access, hardened sshd, updates, Podman and node_exporter.
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
    (Alma minor version, git commit, package diff against the previous
    template);
  - full-clones it to `ct-alma-10-int` on `vmbr0` and converts that too;
  - tests a clone of the new template, then destroys the test clone;
  - on failure deletes the new templates and keeps the old ones; on success
    deletes the previous templates unless a clone task from them is running.
- Add `roles/lxc_base/` (runs inside the CT over SSH): local admin `ops`,
  sshd hardening, a first-boot unit, node_exporter, the weekly update window,
  the subordinate ID range, and the reset before templating.
- Reuse `os_prepare` and `os_container` in the baseline, with two small
  changes: a variable for the dnf-automatic upgrade type (`os_prepare`) and an
  SELinux guard on the two `semanage`/`restorecon` tasks (`os_container`).
- Schedule the playbook in Semaphore every ~3 weeks.
- Dependency: enable `community.proxmox` in `collections/requirements.yml`
  (today commented out) with a version floor, and record it in `TECHSTACK.md`.

## Capabilities

### New Capabilities

- `ct-template-build`: scheduled, tested build and replacement of the LXC
  templates.
- `lxc-base`: baseline and reset of an AlmaLinux 10 LXC guest for templating.

### Modified Capabilities

- None (no accepted spec covers `os_prepare` or `os_container`).

## Impact

- New roles, playbook, role README/AGENTS, `roles/AGENTS.md` index, root
  README playbook list, `TECHSTACK.md` collection row.
- `os_prepare`: new variable, default keeps today's behavior.
- `os_container`: SELinux tasks skip where SELinux is not enabled.
- External: Proxmox API (token from Semaphore secrets), `download.proxmox.com`
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
- Risk: rootful Podman overlay storage inside an unprivileged CT; covered by
  the clone test.
- Risk: the token secret and the build/ops private keys live in Semaphore.

Approval status: scope decided with the user on 2026-10-18 (session in
`lab_01_migrations`); plan created only, not approved for implementation.
