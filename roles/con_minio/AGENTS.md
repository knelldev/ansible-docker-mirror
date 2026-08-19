# con_minio Role

## Purpose

Deploy and configure the MinIO object storage container via Podman Quadlet.

## Local Contracts

- Follows standard `con_*` container-role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `con_minio_*`
- Required before deploy: storage paths, disk capacity, planned access keys and bucket structure

## Work Guidance

### Run

```bash
ansible-playbook playbooks/con_minio.yml -i <inventory>
```

### Post-Run

1. `podman ps | grep minio` — container running
2. Access MinIO UI at configured hostname
3. Create initial buckets and users
4. Test S3 compatibility with AWS CLI

## Verification

```bash
ansible-playbook --syntax-check playbooks/con_minio.yml
ansible-lint roles/con_minio/
podman ps --filter name=minio --format '{{.Names}} {{.State}}'
```

## Child DOX Index

None.
