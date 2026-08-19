# con_semaphore Role

## Purpose

Deploy and configure the Semaphore CI/CD container via Podman Quadlet.

## Local Contracts

- Follows standard `con_*` container-role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `con_semaphore_*`
- Required before deploy: database connection details, planned pipeline configurations

## Work Guidance

### Run

```bash
ansible-playbook playbooks/con_semaphore.yml -i <inventory>
```

### Post-Run

1. `podman ps | grep semaphore` — container running
2. Access Semaphore UI at configured hostname
3. Configure CI/CD pipelines
4. Set up notification channels

## Verification

```bash
ansible-playbook --syntax-check playbooks/con_semaphore.yml
ansible-lint roles/con_semaphore/
podman ps --filter name=semaphore --format '{{.Names}} {{.State}}'
```

## Child DOX Index

None.
