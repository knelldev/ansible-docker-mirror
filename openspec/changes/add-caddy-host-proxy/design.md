## Context

- Repository contracts: `TECHSTACK.md` (role skeleton, FQCN, pinned and
  rootless/rootful conventions), `roles/AGENTS.md` (`con_*` layout,
  numbered tasks, `vars/main.yml` derivations).
- Source of the site shape: `lab_01_migrations/desired/proxy.yaml`.
- Overlaps the planning change `replace-nginx-with-caddy`, which designs a
  central edge with app fragments. This change is the per-host slice only.

## Decisions

### Image

`docker.io/caddybuilds/caddy-cloudflare:2.11.7` (also on GHCR). It rebuilds
on every Caddy release, publishes full version tags, and includes
`caddy-dns/cloudflare`. 2.11.6 is the minimum because of
`tls_automate_names`. Verified locally: the rendered example config passes
`caddy validate` and `caddy fmt` with this image (2026-10-17).

### Certificates

Global `acme_dns cloudflare {env.CF_API_TOKEN}` plus
`tls_automate_names <wildcards>`. Since Caddy 2.10 a managed wildcard serves
all sites below it without per-name certificates (Caddy docs, Automatic
HTTPS, Wildcard certificates). `caddy adapt` shows only the wildcard in
`certificates.automate`. Names outside every wildcard get their own cert.

### Runtime

Rootful Quadlet in `/etc/containers/systemd/caddy.container`, like the other
`con_*` roles, with `Network=host`: Caddy binds 80/443 directly, sees client
addresses, and reaches `127.0.0.1` and LAN upstreams. The admin API stays on
the default `localhost:2019` (host loopback only); `ExecReload` uses
`caddy reload` through `podman exec`. Storage under `/data/caddy`
(`conf`, `errors`, `data`, `config`, `logs`), root-owned 0700, logs 0750.
The Caddyfile directory is mounted, not the file, so atomic replacement is
seen by the container.

### Site model

A list `con_caddy_sites`; each site renders one site block that imports a
`common` snippet (encode, JSON log, `handle_errors 502 503 504` with the
static page). Mutually exclusive `handle` blocks: `robots.txt`, blocked paths
(404), static `responses`, then the catch-all with `redir` or a `route` of
optional authentik forward auth (outpost path proxied, `forward_auth` with an
optional `not path` matcher for skip paths) and `reverse_proxy`. The forward
auth block follows the authentik Caddy example (docs.goauthentik.io).
Input checks run first: name present, upstream or redirect, known `auth` and
`upstream_tls` values, outpost URL set when needed, unique names and aliases.

### PROXY protocol

Optional `servers :443` listener wrapper with an `allow` list.
`fallback_policy` stays at the default `ignore`, so direct internal clients
without a PROXY header still connect (Caddy docs, global options).

## Risks / Trade-offs

- Not tested on a live host: Quadlet start, certificate issuance, reload,
  PROXY protocol from OPNsense and forward auth are unverified.
- `trusted_proxies private_ranges` on forward auth is the authentik example;
  narrow it to the outpost address if needed.
- Host networking means port conflicts with anything else on 80/443.
