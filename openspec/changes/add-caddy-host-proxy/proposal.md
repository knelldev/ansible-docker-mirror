## Why

TLS for the homelab apps ends today on the OPNsense Caddy plugin. The target
layering (migration repo `lab_01_migrations`, change `proxy-npm-to-caddy`,
decision P-D1) gives each app host its own Caddy: OPNsense switches the app to
Layer4 SNI passthrough, and the host Caddy handles TLS, the error page,
robots, compression, static responses and forward auth. That host Caddy needs
a role.

## What Changes

- Add `roles/con_caddy/` and `playbooks/con_caddy.yml`: one rootful Podman
  Quadlet per host with host networking, built from the role skeleton.
- Use the third-party image `docker.io/caddybuilds/caddy-cloudflare`, pinned to
  a full Caddy version (2.11.7), for DNS-01 through Cloudflare.
- Manage wildcard certificates with `tls_automate_names`, so sites under a
  wildcard reuse it and internal names stay out of CT logs.
- Declare sites as a list in role vars, shaped like `desired/proxy.yaml`
  (`name`, `upstream`, `headers_down`, `auth`, `auth_skip_paths`,
  `block_paths`, plus `noindex`, `responses`, `redirect`).
- Per site: compression, JSON access logs for CrowdSec, a static error page
  for 502/503/504, optional authentik forward auth with skip paths.
- Optional PROXY protocol on `:443` for an allowlist (OPNsense).
- Validate the rendered Caddyfile with the pinned image before it replaces the
  active one; reload on change.

## Capabilities

### New Capabilities

- `caddy-host-proxy`: per-host Caddy with DNS-01 wildcard certificates and a
  data-driven site list.

### Modified Capabilities

- None.

## Impact

- New role, playbook, role README/AGENTS, `roles/AGENTS.md` index and root
  README playbook list.
- External: Cloudflare API (token from vault), container registry pull,
  authentik outpost when a site uses forward auth. No existing role changes.

## Scope Boundary And Exclusions

- Narrower than the planning change `replace-nginx-with-caddy`: no shared proxy
  network, no app-owned site fragments, no CORS policies, no per-route health
  checks, no `con_nginx` migration. Those stay in that change (or are dropped
  there) and are not implemented here.
- No firewall changes on the host; ports 80/443 must already be open.
- No live deployment in this change.

## Alternatives And Risks

- Build Caddy with xcaddy in the role: no third-party image, but the repository
  then maintains a build. Rejected, same as in `replace-nginx-with-caddy`.
- Per-name certificates: simpler, but leaks internal names to CT logs.
- Bridge network with published ports: needs `host.containers.internal` for
  local upstreams and loses nothing in return; host networking is simpler.
- Risk: third-party image supply chain. Mitigation: full version pin, no
  `AutoUpdate=registry`, validate with the actual image.
- Risk: the Cloudflare module rejects malformed tokens at validate time, so the
  first run needs a real token in `caddy.env` before the Caddyfile validates.

Approval status: approved by the user on 2026-10-17 ("start caddy/vps as
podman in the same structure"), for implementation on a feature branch. Live
deployment is not approved by this change.
