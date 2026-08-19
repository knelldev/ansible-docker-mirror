# os_container Role

## Purpose

Configure Linux hosts for containerized workloads (Podman runtime, users, sudo, firewall).

## Local Contracts

- Follows standard `os_*` role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `os_container_*`

## Work Guidance

### Run

```bash
ansible-playbook playbooks/os_container.yml -i <inventory>
```

### Post-Run

1. `podman info` — runtime installed
2. Verify users and sudo groups
3. Verify firewall rules applied

## Verification

```bash
ansible-playbook --syntax-check playbooks/os_container.yml
ansible-lint roles/os_container/
podman info
```

## Child DOX Index

None.
