## Why

The repository needs one repeatable quality command before commits. The current
validator has unnecessary scopes and does not put autofix formatters before the
post-fix checks.

## What Changes

- Create `scripts/quality.sh` as the repository-wide quality entry point.
- Run `prettier --write`, `ruff check --fix`, and `black` before their checks.
- Run Ansible, YAML, Python, Markdown, Dockerfile, and shell checks afterward.
- Continue through all checks, aggregate failures, warn on unavailable tools,
  and retain detailed logs locally.
- Document `scripts/quality.sh` as the regular pre-commit quality command.

## Exclusions

- Fixing existing lint or formatting findings.
- Adding tool dependencies or installer automation.
- Keeping role, playbook, or changed-file scopes.

## Approval

- Approved for implementation on 2026-08-13.
