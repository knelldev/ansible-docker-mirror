## Context

Thirteen roles renamed `vars/main.yml` to `vars/main/00-app.yml`. Ansible loads
the standard role entry point automatically, not arbitrary nested files.

## Design

- Move each existing `00-app.yml` content back to `vars/main.yml`.
- Preserve every existing variable and add the derived `app_user` beside
  `app_name` and `app_path` for roles that define those application variables.
- Do not alter task loading, defaults, or public interfaces.
- Treat future variable-layout redesign as separate work.

## Verification

- Confirm each affected role has `vars/main.yml`.
- Run syntax checks for representative affected playbooks.
- Run focused linting where local tooling is available.
