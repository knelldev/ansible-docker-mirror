# con_caddy Role

## Purpose

Deploy a per-host Caddy reverse proxy with Cloudflare DNS-01 certificates via
Podman Quadlet.

## Local Contracts

- Follows the `con_*` layout in [`roles/AGENTS.md`](../AGENTS.md); variables
  prefixed `con_caddy_*`.
- Required before deploy: `con_caddy_acme_email` and
  `con_caddy_cloudflare_api_token` (vault).
- The image stays pinned to a full version with the Cloudflare DNS module; no
  repository-owned Caddy build.
- The Caddyfile is validated with the pinned image before it replaces the
  active file. Keep that `validate` step when changing `20-config.yml`.
- The Cloudflare token appears only in `caddy.env` (0600) and never in task
  output or the Caddyfile.
- Site keys stay close to the migration repository's `desired/proxy.yaml`.

## Work Guidance

### Run

```bash
ansible-playbook playbooks/con_caddy.yml -i <inventory>
```

### Post-Run

1. `systemctl status caddy` — service active
2. `podman logs caddy` — certificates obtained, no errors
3. `curl -I https://<site>` — expected status and headers

## Verification

```bash
ansible-playbook --syntax-check playbooks/con_caddy.yml
ansible-lint roles/con_caddy/ playbooks/con_caddy.yml
yamllint roles/con_caddy/ playbooks/con_caddy.yml
```

## Child DOX Index

None.
