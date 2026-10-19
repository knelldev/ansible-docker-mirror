## Context

Configured validation currently requires manual combinations of `ansible-lint`,
`yamllint`, Python checks, and Ansible syntax checks. The root DOX and
`TECHSTACK.md` require relevant checks but do not provide a reusable entry point
or concise result format.

## Goals / Non-Goals

**Goals:**

- Provide a single dependency-free repository quality command.
- Run all recurring applicable checks and aggregate outcomes.
- Keep detailed command output local and ignored while making terminal output
  short enough for interactive AI and human use.

**Non-Goals:**

- Dependency update automation, automatic remediation, CI replacement, or
  changes to existing lint rules.
- Hiding failures, skipping checks after the first error, or guessing scope from
  changed files.

## Decisions

- Use a POSIX shell entry point under `scripts/` because it works in the
  existing container/Ansible-oriented environment without a new dependency.
  Python was rejected because the required orchestration is small and adds a
  runtime contract.
- Run the whole recurring quality set. Scope selection and changed-file inference
  were rejected because they add command surface without reducing recurring work.
- Run each applicable check independently, capture its complete output to a
  timestamped ignored log directory, and print the summary only after all have
  run. The first summary line is a copyable overall outcome for plan summaries;
  grouped check names follow it while complete failure output remains in logs.
  Fail-fast was rejected because it obscures the complete repair set.
- Keep checks in an append-only registration list near the script top. Add a
  check only when it is recurring and repository-wide; do not create one-time
  command wrappers.
- Use `ansible-lint`, `yamllint`, syntax checks for root playbooks, `black`,
  `pyright`, Prettier for JSON, hadolint for the Dockerfile, and shellcheck for
  repository shell scripts. Jinja templates are checked through Ansible.
  Unavailable tools produce warnings and do not fail a run. Markdownlint is
  advisory when installed and does not fail a normal run.

## Risks / Trade-offs

- Timestamped logs consume local disk space -> retain logs only in ignored
  workspace storage and document their location.
- Full-repository validation may be slow and inherit existing failures -> print
  grouped failures and distinguish tool absence from a failed check.
- Ansible syntax checks only reach statically included task files through a
  playbook's main role tasks -> retain `ansible-lint` and `yamllint` coverage and
  document the dynamic-include limit.

## Migration Plan

1. Add the script and ignored log location.
2. Document its usage and replace ad-hoc recurring quality instructions.
3. Exercise the repository run and record inherited failures without suppressing
   them.
