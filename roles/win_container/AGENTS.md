# win_container Role

## Purpose

Configure Windows hosts for containerized workloads (Docker runtime, users, container settings).

## Local Contracts

- Follows standard `win_*` role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `win_container_*`

## Work Guidance

### Run

```bash
ansible-playbook playbooks/win_container.yml -i <inventory>
```

### Post-Run

1. `docker info` — runtime installed
2. Verify user configuration
3. Test container execution

## Verification

```bash
ansible-playbook --syntax-check playbooks/win_container.yml
ansible-lint roles/win_container/
docker info
```

## Child DOX Index

None.
