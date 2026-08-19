# os_gitlab_runner Role

## Purpose

Install and configure GitLab Runner on Linux hosts.

## Local Contracts

- Follows standard `os_*` role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `os_gitlab_runner_*`
- Two-numbered task files: `01-prepare.yml`, `02-install.yml`

### Utility Files (Not Auto-Discovered)

Manual registration utilities, included explicitly based on runner scope:

- `register.yml` — generic registration
- `register-shared.yml` — shared runner (all projects)
- `register-group.yml` — group-level runner
- `register-project.yml` — project-specific runner
- `register-offline.yml` — offline runner (no GitLab connectivity)

## Work Guidance

Add the role to a playbook and include a registration utility explicitly, e.g.:

```yaml
- hosts: gitlab_runners
  roles:
    - role: os_gitlab_runner
      tags: [register-group]
```

### Post-Run

1. `systemctl status gitlab-runner` — service running
2. Confirm runner in GitLab UI (Settings → CI/CD → Runners)
3. Test runner with a simple pipeline job

## Verification

```bash
ansible-lint roles/os_gitlab_runner/
systemctl is-active gitlab-runner
gitlab-runner list
```

## Child DOX Index

None.
