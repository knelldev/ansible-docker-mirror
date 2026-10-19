## Status

- Plan state: complete; awaiting archive.
- Approval: implementation approved on 2026-08-13.
- Blocker: none.

## Tasks

- [x] Record the approved cleanup scope and expected callback-owned behavior.
- [x] Normalize all role task names by removing filename workarounds and
      redundant quoting and capitalizing action descriptions.
- [x] Update the role skeleton to generate normalized task names.
- [x] Run focused searches, linting, callback discovery, and the local smoke playbook.
- [x] Record verification evidence, complete DOX closeout, sync the specification, and prepare archive.

## Verification Evidence

- Filename-workaround search returns no `task_filename`, `(main.yml)`, or other
  source-filename task-name prefixes under `roles/`.
- `git diff --check` passes.
- `python3 -m py_compile callback_plugins/knelldev_default.py` passes.
- `ansible-doc -t callback knelldev_default` resolves the configured callback.
- `ansible-playbook --syntax-check playbooks/ping_local.yml` passes with the
  expected implicit-localhost inventory warnings.
- `ansible-playbook playbooks/ping_local.yml` passes and displays filename
  prefixes for its task and handler banners.
- `yamllint roles/con_minio/tasks/20-config.yml roles/pve_vm_clone/tasks/10-install.yml`
  has no errors; the former has its pre-existing missing-document-start warning.
- Full `yamllint roles` and `ansible-lint roles` remain non-zero because of
  existing quality debt outside this task-name cleanup. The linters exposed two
  YAML syntax errors caused by optional quote removal; the affected names were
  re-quoted and focused YAML validation now passes.
- DOX closeout: re-read root, roles, role-level, and callback contracts. No
  local contract changed; the accepted source-prefix specification was updated.

## Next Action

- Archived after the main specification sync.
