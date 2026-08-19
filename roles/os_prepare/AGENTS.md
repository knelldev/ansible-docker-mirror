# os_prepare Role

## Purpose

OS-level preparation and setup for containerized workloads. Establishes Podman, users, sudo, and firewall as a reusable baseline before [`os_container`](os_container/AGENTS.md) or [`con_*`](../AGENTS.md) container roles run.

## Local Contracts

- Follows standard `os_*` role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `os_prepare_*`
- Task files use **descriptive** naming (`10-install.yml`, `20-configure.yml`, `30-customize.yml`) instead of the canonical `00-prepare / 10-install / 20-config`. The two-digit prefix still matches the `main.yml` glob `[0-9][0-9]-*.yml`, so the parent auto-discovery rule still applies — these are auto-discovered, not manually included.

## Work Guidance

### Run

```bash
ansible-playbook playbooks/os_prepare.yml -i <inventory>
```

### Post-Run

1. `podman info` — runtime installed
2. Verify user/sudo configuration
3. Verify firewall rules applied

## Verification

```bash
ansible-playbook --syntax-check playbooks/os_prepare.yml
ansible-lint roles/os_prepare/
podman info
```

## Child DOX Index

None.
