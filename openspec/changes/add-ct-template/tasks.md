## Status

- Approval: approved for implementation 2026-10-18 (user, herdr-inbox Q3,
  with the decisions folded into `design.md`).
- Repository tasks 1.1 to 1.6 done; live tasks 2.2 to 2.4 need approval per
  step.
- CT-Q5 (diff baseline) and CT-Q6 (dnf-automatic on existing hosts)
  resolved (user, 2026-10-18), implemented in `pve_ct_template` and
  `os_prepare`.
- Live build (2.2) scheduled by the user for Monday 2026-10-20 afternoon.

## 1. Repository

- [x] 1.1 Enable `community.proxmox` with a version floor in
      `collections/requirements.yml`; add it to `TECHSTACK.md`.
- [x] 1.2 Check whether `proxmox_template` `url` downloads on the node; else
      use `uri` with `download-url`. (Node-side in both paths; role uses the
      `aplinfo` path, see `design.md`.)
- [x] 1.3 `os_prepare`: add `os_prepare_dnf_automatic_upgrade_type`
      (default `default`). `os_container`: SELinux guard on the two
      `semanage`/`restorecon` tasks; optional `os_container_subid_min/max`;
      optional `os_container_default_netns` and
      `os_container_unprivileged_port_start`.
- [x] 1.4 Extend `roles/os_prepare/`, one switch per part: admin user,
      first-boot unit, node_exporter (EPEL `node-exporter`), weekly update
      window (dnf 4.20 on Alma 10, `reboot` documented).
      Create `roles/os_template_reset/` with the reset list as a variable.
- [x] 1.5 Create `roles/pve_ct_template/` and `playbooks/pve_ct_template.yml`:
      guard, download, build CT, baseline, template, int clone, test, swap,
      rescue.
- [x] 1.6 READMEs, AGENTS, `roles/AGENTS.md` index, root README.

## 2. Verification

- [x] 2.1 `ansible-lint` (production), `yamllint`, syntax check.
- [ ] 2.2 Live build on `pve` (needs approval; scheduled by the user for
      Monday 2026-10-20 afternoon): templates, notes, clone test;
      also verifies the [unverified] items in `design.md` (unprivileged port
      sysctl in an unprivileged CT, node_exporter unit, `vzclone` task id).
      The first build has no previous package list; the diff against the
      previous template shows from the second build on.
- [ ] 2.3 Forced failure (needs approval): old templates stay, new ones gone.
- [ ] 2.4 Semaphore schedule every ~3 weeks, environment variables from
      `roles/pve_ct_template/README.md`.

## Verification Evidence

- 2026-10-18: planning artifacts only; `openspec validate add-ct-template
  --strict` passes.
- 2026-10-18 (implementation, local only, no live system contacted):
  - `ansible-lint playbooks/pve_ct_template.yml roles/pve_ct_template
    roles/os_template_reset roles/os_prepare roles/os_container`
    (production profile, ansible-lint 26.10.1): no findings in new files;
    8 findings remain, all pre-existing in unchanged lines of `os_prepare`
    and `os_container` (meta document start, `storage_base_path` prefix,
    `graphroot_lineinfile` prefix, `30-customize` shell, `20-configure`
    task name).
  - `yamllint` on the same paths: only the 2 pre-existing meta
    document-start warnings.
  - `ansible-playbook --syntax-check playbooks/pve_ct_template.yml`: passes.
  - Failure path run with no secrets set (`-i localhost,`): input check
    fails, rescue records it, guest plays skip, finish play fails the run
    with the message; no API call made.
  - Jinja filters (package list, old/leftover selection, IP parsing, image
    pick, busy-template filter) checked against sample data in a scratch
    playbook.
  - `openspec validate add-ct-template --strict`: passes.

- 2026-10-18 (CT-Q5/CT-Q6 follow-up, local only): same `ansible-lint`
  run: the same 8 pre-existing findings, none in changed lines; `yamllint`:
  the same 2 meta warnings; syntax check passes; no-secrets failure path
  as before; notes composition checked in a scratch playbook with a real
  AlmaLinux 10 package list (296 packages: notes 4746 characters with list;
  300-line stock diff cut to exactly 8000; list left out when the minimum
  text does not fit); `pkglist.gz.b64` line read back with the role's
  regex and unpacked with `base64 -d | gzip -dc` to the same 296 lines;
  `openspec validate add-ct-template --strict` passes.

## Next Action

- User, Monday 2026-10-20 afternoon: set the Semaphore environment, then
  run task 2.2 (live build on `pve`).
