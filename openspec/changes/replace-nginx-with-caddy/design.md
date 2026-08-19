## Context

The existing `con_nginx` role deploys an upstream Nginx image through Podman
Quadlet, publishes ports 80/443, writes configuration and certificate files
under a storage path, and runs a separate Cloudflare Certbot container. Its
route behavior is spread across Nginx templates and defaults, including
Authentik-specific snippets and an SSI-based error page. The new role must
follow the repository's `con_*` role and rootless Quadlet contracts in
`TECHSTACK.md` and `roles/AGENTS.md`, while remaining independently deployable
for a controlled migration.

## Goals / Non-Goals

**Goals:**

- Establish one typed route data model that renders deterministic Caddy
  configuration and validates unsafe or ambiguous inputs early.
- Use a vetted third-party Caddy image with no repository-maintained custom
  proxy image.
- Make Caddy a standalone global edge that can run with zero application routes.
- Keep Caddy as the only public container endpoint and connect integrated
  applications through one shared private proxy network.
- Allow application roles to run independently and optionally render only their
  own Caddy site fragment.
- Use a third-party prebuilt Caddy image with the Cloudflare DNS module while
  maintaining no repository-owned Caddy image or build, and support DNS-01,
  renewal, permissions, and safe reload handoff.
- Make Authentik forward-auth, per-route CORS, security headers, managed errors,
  logging, and health checks testable behaviors.
- Support side-by-side deployment and a reversible cutover from Nginx.

**Non-Goals:**

- Do not modify or remove `con_nginx` in the initial implementation.
- Do not create a repository-owned Caddy image, Caddy plugin build pipeline, or
  external certificate issuer.
- Do not invent a generic WAF, rate-limit service, dashboard, public admin
  endpoint, or application-specific authorization model.
- Do not claim security equivalence until rendered-config, TLS, authentication,
  CORS, and failure-path tests pass in a controlled environment.

## Decisions

### New role rather than in-place replacement

Create `roles/con_caddy/` and `playbooks/con_caddy.yml`. This preserves the
current Nginx deployment as a rollback path and avoids silently changing the
existing variable contract. A later cutover can retire Nginx after explicit
validation.

### Rootless Quadlet with third-party Caddy image

Run the approved third-party Caddy image using the same rootless Podman/Quadlet
pattern used by existing `con_*` roles. Mount only managed configuration, data,
config, and error assets. The container publishes 80/443; integrated
application containers publish no host ports. A host package was rejected
because it would split this repository's container operations model, while a
repository-owned Caddy build was rejected because it creates image maintenance.

### Global Caddy ownership and optional app integration

`con_caddy` owns the Caddy Quadlet, public ports, shared `caddy_proxy` network,
core `Caddyfile`, global snippets, certificate credentials/state, security
policy, error assets, and the assembled configuration lifecycle. It MUST work
with no site fragments and MUST NOT require application services to start.

An application role may opt in with a role-prefixed boolean such as
`con_<app>_caddy_enabled`. When enabled, it joins the shared proxy network and
owns only a namespaced fragment such as `sites-enabled/<app>.caddy`. It MUST
NOT write the core Caddyfile, global snippets, certificates, credentials,
public ports, or arbitrary global directives. When disabled or removed, it
removes its own fragment and requests configuration validation/reload when
Caddy is available.

The roles MUST remain independently runnable. Caddy can be deployed, validated,
enabled, or started without an app. Installation and validation MUST be
separable from startup so the role can be applied after OS/Podman setup without
starting the public edge until explicitly requested. An app can deploy without
Caddy when its integration flag is disabled. If the app runs first, its
fragment remains until Caddy is installed and imports it; if Caddy runs first,
it starts with zero routes and later reloads when an app fragment is added.

The shared network is preferred over joining Caddy to every application's
internal network. Integrated applications expose their service only to that
shared network using their container name and internal port.

### Third-party Caddy image with Cloudflare module

Use a third-party prebuilt Caddy image that explicitly includes the Cloudflare
DNS module, rather than building Caddy in this repository. The image reference
MUST be pinned to a reviewed tag or digest, its provenance and module contents
MUST be recorded, and the actual image MUST pass configuration and renewal
checks before use. Caddy's native DNS-01 automation owns issuance and renewal;
the role still manages restrictive credential input, certificate storage,
readiness, and reload-after-success. A repository-owned Caddy build and an
additional issuer container are excluded by this decision.

### Caddyfile and controlled fragment import

Render one core Caddyfile that imports only controlled core snippets and a
controlled `sites-enabled/*.caddy` glob. Caddy's `import` directive is suitable
because an empty glob is valid, allowing a route-free standalone edge.
Application fragments contain complete site blocks generated from an approved
contract. They are not arbitrary global configuration escapes. Validate the
assembled configuration with the selected image before starting or reloading;
keep the active configuration intact when validation fails.

### Route model with explicit policy blocks

Represent routes with fields for hostnames, matcher/path, upstream, network,
TLS/certificate reference, authentication mode, CORS policy, headers, health
check, and optional narrowly scoped transport settings. Defaults are deny-first:
no CORS, no public admin, no trust of client identity headers, and no HSTS until
the route opts in. Duplicate route identity, malformed upstreams, unsupported
methods, and invalid CORS credential combinations fail before service reload.

### Authentik forward authentication at the edge

Use an Authentik-compatible forward-auth flow rather than embedding an
application-specific login implementation. The route proxy sends an auth
subrequest, does not send rejected requests upstream, and copies only selected
identity response headers into the upstream request. The callback/outpost path
is an explicit integration setting and is not a general bypass.

### Per-route CORS with generated preflight handling

Generate CORS behavior only for routes that declare it. Origins are explicit;
credentials require non-wildcard origins; allowed methods and headers are
validated lists. This is safer than a global permissive policy and keeps policy
close to the application route.

### Error page and observability

Use a static managed error asset with no SSI or request-variable interpolation
that could expose sensitive data. Configure access/error logs through the
container's normal rootless logging path and use route-level health checks after
deployment. Do not expose Caddy's admin API or metrics publicly.

### Service dependencies and health checks

Caddy MUST depend only on its own network and storage prerequisites, never on
application services. An integrated application may optionally order itself
after Caddy, but Caddy must not require an application. Fragment changes use a
shared service-level validation/reload operation that validates the complete
assembled configuration before reloading it. The operation is safe to request
when Caddy is stopped; the Quadlet service owns the reload command and app
roles only request the documented handler/service contract.

Health checks are layered: the app role checks its own container directly, then
performs an HTTPS edge check only when integration is enabled and Caddy is
available. The global role checks Caddy and can succeed with no app routes.
Quadlet startup readiness and post-app-deployment edge readiness are separate
checks.

## Risks / Trade-offs

- [Third-party image supply chain] -> Pin a digest where practical, record
  provenance and module verification evidence, validate the image before
  deployment, and retain a rollback image reference.
- [Certificate automation coordination] -> Use readiness checks, retained
  last-good certificates, and reload only after complete valid material.
- [Rootless networking may not reach every application topology] -> Require an
  explicit network/upstream contract per route and test each supported topology.
- [Authentik integration semantics may differ from Nginx auth_request] -> Test
  unauthenticated, authenticated, callback, cookie, redirect, and identity
  header cases against the selected Authentik endpoint.
- [CORS headers can be application-sensitive] -> Default deny, validate policy
  combinations, and require per-route opt-in with integration tests.
- [Migration can cause port conflicts] -> Run side-by-side on a non-conflicting
  validation host or use a planned stop/cutover window; preserve Nginx units and
  document rollback before binding 80/443.
- [Caddy syntax or feature assumptions can age] -> Pin/record the tested image
  reference, validate with the actual image, and avoid unsupported directives.
- [Role execution order] -> Make imports tolerate an empty site directory,
  keep app fragments independently managed, and validate/reload after fragment
  changes instead of relying on role order.
- [Stale or conflicting app fragments] -> Require namespaced ownership, remove
  fragments when integration is disabled, and reject duplicate hostname/path
  identities before reload.

## Migration Plan

1. Implement and validate the global role without changing `con_nginx` or app
   roles by default.
2. Prepare the shared network, certificate policy, Authentik settings, and a
   non-production or isolated validation target.
3. Enable one pilot application integration and verify fragment ownership,
   private networking, complete-config reload, and layered health checks.
4. Run configuration, TLS, route, auth, CORS, error, and private-port checks.
5. Enable additional app integrations one at a time and verify each edge route.
6. Stop or move the existing Nginx listener during an approved cutover window,
   start Caddy, and run external smoke tests for every route.
7. Roll back by stopping Caddy and restoring the Nginx Quadlet units/configuration
   if any required route, certificate, or authentication check fails.
8. Retire Nginx only in a later explicitly approved change after an observation
   period and confirmed certificate renewal.

## Open Questions

- Which third-party image repository and maintainer will be accepted? This is a
  supply-chain approval gate, not an implementation detail.
- What minimum supported Caddy image tag/digest should be recorded when the
  implementation starts? It must be verified against the chosen directives,
  Cloudflare module, and repository runtime policy.
