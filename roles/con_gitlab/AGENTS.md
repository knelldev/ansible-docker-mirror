# con_gitlab Role

## Purpose

Deploy and configure the GitLab container via Podman Quadlet.

## Local Contracts

- Follows standard `con_*` container-role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `con_gitlab_*`
- Required before deploy: GitLab license, registration token, planned storage/backup paths

## Work Guidance

### Run

```bash
ansible-playbook playbooks/con_gitlab.yml -i <inventory>
```

### Post-Run

1. `podman ps | grep gitlab` — container running
2. Access GitLab UI at configured hostname
3. Complete initial setup wizard
4. Configure backup schedule

## Verification

```bash
ansible-playbook --syntax-check playbooks/con_gitlab.yml
ansible-lint roles/con_gitlab/
podman ps --filter name=gitlab --format '{{.Names}} {{.State}}'
```

## Child DOX Index

None.
