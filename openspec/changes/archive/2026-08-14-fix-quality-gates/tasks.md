## Status

- Plan state: complete.
- Approval: implementation approved on 2026-08-13.

## Tasks

- [x] Replace the scoped validator with repository-wide `scripts/quality.sh`.
- [x] Put Prettier, Ruff, and Black autofix stages before post-fix checks.
- [x] Document pre-commit use and the unavailable/advisory tool policy.
- [x] Validate the script, record existing quality failures, and complete closeout.

## Verification Evidence

- `sh -n scripts/quality.sh` passes.
- `git diff --check -- scripts/quality.sh README.md openspec/changes/fix-quality-gates` passes.
- `openspec validate fix-quality-gates --strict` reports that the change is valid.
- `scripts/quality.sh` completes all configured checks and reports:
  `RESULT: quality FAIL (4/29 checks, 2 skipped); logs: .validation-logs/20260814T013008-quality`.
- Existing required-check failures are `ansible-lint`, `yaml-lint`,
  `python-types`, and `dockerfile-lint`; these remain outside this change's
  scope.
- `pylint` is unavailable and `markdownlint` is advisory, so both are reported
  as warnings without changing the required-check result.

## Next Action

- Archive this completed change with `openspec archive --change fix-quality-gates`.
