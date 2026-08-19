# con_nginx Role

## Purpose

Deploy and configure the Nginx reverse proxy container via Podman Quadlet.

## Local Contracts

- Follows standard `con_*` container-role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `con_nginx_*`
- Required before deploy: SSL certificates, planned upstream servers and routing rules

## Work Guidance

### Run

```bash
ansible-playbook playbooks/con_nginx.yml -i <inventory>
```

### Post-Run

1. `podman ps | grep nginx` — container running
2. Test reverse proxy functionality
3. Verify SSL/TLS configuration
4. Monitor access logs

## Verification

```bash
ansible-playbook --syntax-check playbooks/con_nginx.yml
ansible-lint roles/con_nginx/
podman ps --filter name=nginx --format '{{.Names}} {{.State}}'
```

## Child DOX Index

None.
