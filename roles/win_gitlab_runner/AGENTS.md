# win_gitlab_runner Role

## Purpose

Install and configure GitLab Runner on Windows hosts.

## Local Contracts

- Follows standard `win_*` role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `win_gitlab_runner_*`
- Two-numbered task files: `01-prepare.yml`, `02-install.yml`

### Utility Files (Not Auto-Discovered)

Manual registration utilities, included explicitly based on runner scope:

- `register.yml` — generic registration
- `register-shared.yml` — shared runner (all projects)
- `register-group.yml` — group-level runner
- `register-project.yml` — project-specific runner

## Work Guidance

### Run

```bash
ansible-playbook playbooks/win_gitlab_runner.yml -i <inventory>
```

Add additional runners:

```bash
ansible-playbook playbooks/win_gitlab_runner.yml -i <inventory> -t register-group
```

### Post-Run

1. `Get-Service gitlab-runner` — service running
2. Confirm runner registered in GitLab UI
3. Test runner with sample pipeline

## Verification

```bash
ansible-playbook --syntax-check playbooks/win_gitlab_runner.yml
ansible-lint roles/win_gitlab_runner/
```

## Child DOX Index

None.
