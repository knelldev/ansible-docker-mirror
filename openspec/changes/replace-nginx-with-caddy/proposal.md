## Why

The repository's current `con_nginx` role combines reverse proxying, custom
configuration fragments, error rendering, Authentik integration, and
Cloudflare-backed certificate issuance in a way that is difficult to extend
and easy to misconfigure. A Caddy-based role can provide a smaller, more
declarative public edge while keeping application containers private and
avoiding a maintained custom proxy image.

## What Changes

- Add a new `con_caddy` role and playbook; leave `con_nginx` available during
  migration rather than silently changing its behavior.
- Deploy a vetted third-party Caddy image through rootless Podman Quadlet,
  without a repository-maintained Caddy image or Dockerfile.
- Make `con_caddy` the sole owner of the global edge, public ports, shared
  network, certificates, global policy, and assembled Caddy configuration.
- Keep proxied applications off published host ports; publish only Caddy's
  HTTP and HTTPS ports and connect applications to the shared private proxy
  network when explicitly integrated.
- Let application roles optionally own only their own `sites-enabled/<app>.caddy`
  fragment, with no unconditional dependency on Caddy.
- Model routes as typed variables with explicit upstreams, hostnames, paths,
  headers, health behavior, and optional Authentik forward authentication.
- Provide secure default TLS, security headers, method/request limits, access
  logging, upstream failure handling, and a custom error page without leaking
  upstream details.
- Support per-route CORS policies with explicit origins and safe defaults that
  do not enable wildcard credentials.
- Support Cloudflare DNS-01 certificates through a third-party prebuilt Caddy
  image that includes the Cloudflare DNS module; this repository maintains no
  Caddy image or build pipeline.
- Validate the complete assembled configuration before starting or reloading
  Caddy, preserving the active configuration when an app fragment is invalid.
- Coordinate app fragment changes, app removal, Caddy startup, reloads, and
  edge health checks without requiring a fixed role execution order.
- Permit the global role to install and validate Caddy without automatically
  starting it; startup is an explicit service-state choice or an approved app
  integration action.
- Document migration, rollback, certificate prerequisites, Authentik contract,
  private-network requirements, and operational checks.

## Capabilities

### New Capabilities

- `caddy-edge-proxy`: A rootless Caddy edge proxy with private upstreams,
  secure defaults, authentication, errors, CORS, operational validation, and
  optional application-owned site fragments and controlled startup/reload.
- `caddy-cloudflare-certificates`: Cloudflare DNS-01 certificate issuance and
  renewal through a vetted third-party Caddy image without a repository-owned
  Caddy image or build.

### Modified Capabilities

- None.

## Impact

- New `roles/con_caddy/` role, playbook, documentation, and OpenSpec coverage.
- Podman Quadlet units, Caddyfile/configuration rendering, shared private
  container network, mounted certificates, app-owned fragments, and host ports
  80/443.
- Authentik forward-auth endpoint, third-party image provenance, and Cloudflare
  DNS API token are external integrations; credentials must remain
  inventory/vault supplied.
- Existing `con_nginx` files and application roles remain unchanged in this
  planning change and are
  excluded from the first implementation until migration and cutover are
  explicitly approved.

## Alternatives And Risks

- A repository-owned Caddy build with the Cloudflare DNS plugin would make
  DNS-01 native, but it conflicts with the goal of not maintaining a proxy
  image.
- Stock Caddy with HTTP-01 would reduce moving parts but does not meet the
  Cloudflare DNS-01 requirement for wildcard or DNS-only domains.
- A third-party prebuilt image avoids a local build while introducing an
  upstream supply-chain and release-tracking dependency; the design must pin
  and verify the selected image.
- Keeping Nginx avoids migration risk but preserves its fragmented templates
  and does not provide the requested extensible route model.
- Native Caddy certificate automation introduces certificate lifecycle and
  plugin-image coordination; the design must define readiness, renewal,
  permissions, and failure behavior explicitly.
- Authentik forward-auth and CORS behavior require controlled integration tests;
  the plan must not claim equivalent security until those checks pass.

Approval status: planning only. No implementation is authorized by this
proposal; implementation requires a later explicit apply request and approval
of the selected third-party image reference and migration decisions.
