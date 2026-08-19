# win_prepare Role

## Purpose

Windows OS preparation and setup for containerized workloads. Establishes PowerShell modules, users, and dev environment as a baseline before [`win_container`](win_container/AGENTS.md) or Windows GitLab Runner installs.

## Local Contracts

- Follows standard `win_*` role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `win_prepare_*`

## Work Guidance

### Post-Run

1. `Get-Module -ListAvailable` — modules installed
2. Verify user configuration
3. Test development environment

## Verification

```bash
ansible-playbook --syntax-check playbooks/win_container.yml
ansible-lint roles/win_prepare/
```

There is currently no standalone `playbooks/win_prepare.yml`; use
`playbooks/win_container.yml` or `playbooks/win_gitlab_runner.yml` for the
implemented preparation paths.

## Child DOX Index

None.
