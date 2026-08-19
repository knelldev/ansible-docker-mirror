## Why

Markdown lint is currently advisory in `scripts/quality.sh`, while repository
DOX files contain historical long lines and the project has not adopted a
single Markdown style contract.

## Outcome

Decide whether Markdown lint becomes a blocking check, which files it covers,
and which formatting rules are compatible with DOX and OpenSpec records.

## Scope

- Define lint ownership and configuration.
- Separate actionable documentation errors from legacy contract files.
- Record the acceptance threshold and migration approach.

## Exclusions

- No broad Markdown reformat in this planning change.

Approval status: planning only.
