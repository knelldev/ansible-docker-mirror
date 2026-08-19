## Context

The repository requires FQCN, idempotence, role skeleton, and README
contracts, while current roles contain legacy generated content and lint
violations. Work must be incremental and preserve unrelated user changes.

## Decisions Required

- Prioritize security/idempotence violations before style-only findings.
- Decide whether shared variables may remain unprefixed during migration.
- Define treatment of planning-only roles such as `os_mount` and `os_vps`.
- Define acceptable collection and platform verification in local CI.

## Verification Shape

Each approved role batch must pass targeted syntax, lint, YAML checks, and
behavior-preserving tests or documented controlled-host evidence.
