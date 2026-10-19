## Context

The quality script runs Markdown lint as advisory while other checks are
blocking. Any change must preserve concise DOX guidance and avoid formatting
churn in historical OpenSpec records.

## Decisions Required

- Select Markdown files and directories covered by the blocking policy.
- Choose line length, heading, link, and fence rules.
- Decide whether `.markdownlint.yaml` is a repository contract.
- Define a staged cleanup and an explicit exception policy.

## Verification Shape

The selected command must run locally and in CI with the same file set and
produce a clear pass/fail result.
