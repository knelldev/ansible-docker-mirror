## Status

- Approval: plan created only; not approved for implementation.
- Blocker: open questions CT-Q1 to CT-Q5 in `design.md`; live runs need
  per-step approval.

## 1. Repository

- [ ] 1.1 Enable `community.proxmox` with a version floor in
      `collections/requirements.yml`; add it to `TECHSTACK.md`.
- [ ] 1.2 Check whether `proxmox_template` `url` downloads on the node; else
      use `uri` with `download-url`.
- [ ] 1.3 `os_prepare`: add `os_prepare_dnf_automatic_upgrade_type`
      (default `default`). `os_container`: SELinux guard on the two
      `semanage`/`restorecon` tasks.
- [ ] 1.4 Create `roles/lxc_base/` from the skeleton: `ops`, sshd, first-boot
      unit, node_exporter (decide source), weekly update window (check
      `reboot = when-needed` on Alma 10), subuid range, reset task file.
- [ ] 1.5 Create `roles/pve_ct_template/` and `playbooks/pve_ct_template.yml`:
      guard, download, build CT, baseline, template, int clone, test, swap,
      rescue.
- [ ] 1.6 READMEs, AGENTS, `roles/AGENTS.md` index, root README.

## 2. Verification

- [ ] 2.1 `ansible-lint` (production), `yamllint`, syntax check.
- [ ] 2.2 Live build on `pve` (needs approval): templates, notes, clone test.
- [ ] 2.3 Forced failure (needs approval): old templates stay, new ones gone.
- [ ] 2.4 Semaphore schedule every ~3 weeks.

## Verification Evidence

- 2026-10-18: planning artifacts only; `openspec validate add-ct-template
  --strict` passes.

## Next Action

- Answer CT-Q1 to CT-Q5, then approve or revise the plan.
