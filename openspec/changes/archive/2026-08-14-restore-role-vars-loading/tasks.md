## Status

- Approval: implementation approved by user on 2026-08-14.
- Blocker: none.

## Tasks

- [x] Inventory each affected role and confirm its current nested variable file.
- [x] Restore the files to `vars/main.yml`, preserving all content and adding
      derived `app_user` where `app_name` and `app_path` are defined.
- [x] Verify no task includes are needed for the restored variables.
- [x] Run targeted syntax and lint checks.
- [x] Record resulting paths and verification evidence.

## Verification Evidence

- All affected roles have `vars/main.yml` and no longer have `vars/main/`.
- Existing nested variable content was preserved, including the additional
  GitLab Runner and K3s variables.
- Application roles expose `app_name`, `app_path`, and derived `app_user`.
- `ansible-playbook --syntax-check` passed for 11 affected playbooks.
- `openspec validate --specs` passed: 1 specification.
- `git diff --check` passed.
- Focused `ansible-lint` passed for the flattened files except for two existing
  unprefixed `os_gitlab_runner` variables preserved from the nested file.
- Full affected-role lint remains non-zero because of pre-existing findings in
  unrelated role tasks, defaults, and metadata.
- The repository inventory is unavailable locally, so syntax checks emitted
  inventory warnings but completed successfully.
- Empty `vars/main/` directories were removed; `vars/main.yml` is now the only
  standard role variable entry point.

## Next Action

- Request outcome confirmation before OpenSpec closeout or archive.
