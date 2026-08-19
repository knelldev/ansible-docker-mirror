# con_watchtower Role

## Purpose

Deploy and configure the Watchtower auto-update container via Podman Quadlet.

## Local Contracts

- Follows standard `con_*` container-role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `con_watchtower_*`
- Required before deploy: Docker Hub credentials (if needed), planned update schedule, notification preferences

## Work Guidance

### Post-Run

1. `podman ps | grep watchtower` — container running
2. Test automatic update functionality
3. Configure notification channels
4. Monitor update logs

## Verification

ansible-lint roles/con_watchtower/
podman ps --filter name=watchtower --format '{{.Names}} {{.State}}'

```

## Child DOX Index

None.
```
