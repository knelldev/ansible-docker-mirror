# con_caddy Role

## Purpose

Deploy a per-host Caddy reverse proxy with Cloudflare DNS-01 or HTTP-01
certificates via Podman Quadlet. Replaces the deprecated `con_nginx`.

## Local Contracts

- Follows the `con_*` layout in [`roles/AGENTS.md`](../AGENTS.md); variables
  prefixed `con_caddy_*`.
- Required before deploy: `con_caddy_acme_email`, and
  `con_caddy_cloudflare_api_token` (vault) when any site uses DNS-01; an
  assert in `00-prepare.yml` enforces the token, not the sentinel.
- Defaults stay generic (`example.com`); every extra is off by default.
- Host networking is the default; `con_caddy_networks` replaces it, because
  Podman cannot combine host networking with other networks.
- Global DNS-01 uses `cert_issuer`, not `acme_dns`: `acme_dns` would also
  force DNS-01 on per-site `http` issuers.
- Existing site and authentik variables stay backward compatible.
- Default security headers use `header ?Name`, so upstream headers win.
- `handle_errors` covers only errors Caddy raises; never intercept upstream or
  forward auth responses.
- `files/error.html` is a Caddy template; escape literal `{{` as `{{ "{{" }}`.
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
