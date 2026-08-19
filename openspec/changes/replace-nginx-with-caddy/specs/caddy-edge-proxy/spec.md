## Purpose

Provide a declarative, extensible public reverse-proxy capability that keeps
application services private while applying consistent authentication,
transport, error, header, and cross-origin controls.

## ADDED Requirements

### Requirement: Global edge and private upstream boundary
The deployment MUST publish only the configured HTTP and HTTPS edge ports, and
each upstream MUST be reachable by Caddy through an explicitly configured
private container network or host-local endpoint without publishing the
upstream application's port to the host.

#### Scenario: Private application route
- **WHEN** a route is configured for an application on a private network
- **THEN** Caddy proxies the request through that network and the application
  port is not bound on the host

#### Scenario: Missing upstream network
- **WHEN** a route references an unavailable or undeclared network
- **THEN** validation fails before the proxy service is restarted

#### Scenario: Route-free edge
- **WHEN** Caddy is deployed before any application integration is enabled
- **THEN** Caddy can validate and run with its global policy, TLS automation,
  error handling, and no imported application routes

### Requirement: Application-owned site fragments
The global Caddy role MUST own the core configuration, shared snippets,
public ports, shared proxy network, and controlled site-fragment directory.
An integrated application role MUST own only its namespaced site fragment and
MUST remove that fragment when its integration is disabled or removed. The
fragment MUST be generated from the approved route contract and MUST NOT
override global security, TLS, admin, or credential settings.

#### Scenario: Application integrates after Caddy
- **WHEN** an application enables Caddy integration after the global edge is
  already running
- **THEN** the application joins the shared private network, writes only its
  own fragment, and the complete configuration is validated and reloaded

#### Scenario: Application deploys before Caddy
- **WHEN** an application writes its enabled fragment before Caddy is deployed
- **THEN** the fragment remains available and Caddy imports it after the core
  role creates the controlled directory

#### Scenario: Application integration disabled
- **WHEN** an application disables or removes its Caddy integration
- **THEN** its fragment is removed and Caddy reloads only after the resulting
  configuration validates

### Requirement: Independent role lifecycle
The Caddy role MUST run without any application role or application service.
Application roles MUST run without Caddy when integration is disabled. Caddy
MUST NOT require application services through a hard service dependency.

#### Scenario: Caddy without applications
- **WHEN** only the Caddy role is applied
- **THEN** the edge service can be validated and started without route failures

#### Scenario: App without Caddy
- **WHEN** an application role runs with Caddy integration disabled
- **THEN** the application deploys and performs its direct health check without
  requiring Caddy or an edge route

#### Scenario: Install without startup
- **WHEN** the global role is applied with startup disabled
- **THEN** it creates and validates the Quadlet, network, directories, and
  assembled configuration without starting the public Caddy service

### Requirement: Explicit route contract
Each route MUST declare a hostname and upstream, MAY declare a path matcher and
transport options, and MUST reject ambiguous duplicate host/path combinations
or unsafe unvalidated configuration values before deployment.

#### Scenario: Valid route rendering
- **WHEN** a route has a unique hostname, valid upstream, and supported options
- **THEN** the rendered Caddy configuration contains one deterministic route

#### Scenario: Duplicate route rejection
- **WHEN** two routes claim the same hostname and path match
- **THEN** the role fails validation and does not apply the configuration

### Requirement: Secure transport and proxy defaults
The edge MUST redirect HTTP to HTTPS unless explicitly disabled for a documented
exception, use modern TLS defaults, preserve the original host and forwarding
context, and emit security headers that do not expose proxy or upstream
identity. HSTS MUST be opt-in or gated by an explicit domain readiness setting.

#### Scenario: HTTPS request
- **WHEN** a client connects over HTTPS to a valid route
- **THEN** the request reaches the configured upstream with trusted forwarding
  headers and the configured security headers

#### Scenario: HTTP request
- **WHEN** a client connects over HTTP and no exception is configured
- **THEN** the edge redirects the client to the equivalent HTTPS URL

### Requirement: Route authentication
Routes MUST support optional Authentik forward authentication without exposing
the upstream before authentication succeeds. Authentication endpoints and
callback paths MUST be explicitly excluded only where required by the selected
Authentik integration, and authenticated identity headers MUST be controlled by
the proxy rather than trusted from the client.

#### Scenario: Unauthenticated protected request
- **WHEN** a client requests a protected route without a valid Authentik
  session
- **THEN** the request is denied or redirected to Authentik and is not sent to
  the upstream

#### Scenario: Authenticated protected request
- **WHEN** Authentik accepts the request
- **THEN** Caddy proxies it and forwards only the configured authenticated
  identity claims

### Requirement: CORS is explicit per route
The role MUST default to no cross-origin allowance and MUST allow CORS only
through an explicit per-route policy. A policy MUST define allowed origins and
MUST reject wildcard origins when credentials are enabled.

#### Scenario: Allowed preflight
- **WHEN** a route explicitly allows the request origin, method, and headers
- **THEN** the preflight receives the configured CORS response headers

#### Scenario: Disallowed origin
- **WHEN** a request origin is not in the route allowlist
- **THEN** Caddy does not grant cross-origin access

### Requirement: Controlled error responses
The edge MUST return a managed error page for configured proxy and edge errors,
MUST avoid disclosing upstream addresses or implementation details, and MUST
provide a non-proxied health or error response path only when explicitly
configured.

#### Scenario: Upstream unavailable
- **WHEN** the upstream cannot be reached or returns a configured gateway error
- **THEN** the client receives the managed error response without upstream
  connection details

#### Scenario: Error asset unavailable
- **WHEN** the managed error asset is missing or invalid
- **THEN** deployment validation fails rather than silently exposing a default
  server response

### Requirement: Configuration and service validation
The role MUST validate the rendered Caddy configuration before activating it,
must make configuration and secret files restrictive, and MUST support
idempotent reruns without unnecessary service restarts when effective inputs
are unchanged.

#### Scenario: Invalid rendered configuration
- **WHEN** Caddy rejects the rendered configuration
- **THEN** the current running configuration remains active and the role fails

#### Scenario: Unchanged rerun
- **WHEN** the role runs again with unchanged effective inputs
- **THEN** managed files remain unchanged and the service is not restarted solely
  because the role ran

#### Scenario: Invalid application fragment
- **WHEN** an application fragment makes the assembled Caddy configuration
  invalid
- **THEN** the reload is rejected, the previous active configuration remains,
  and currently working routes continue using that configuration

#### Scenario: Reload requested while stopped
- **WHEN** an app role requests the shared reload operation while Caddy is
  stopped
- **THEN** the complete configuration is validated and the operation does not
  create an implicit hard dependency or unexpectedly start Caddy

### Requirement: Observable access and service health
The deployment MUST provide structured access/error logs through the service's
normal rootless container logging path, MUST expose no administrative Caddy
endpoint publicly by default, and MUST offer a configurable post-deploy health
check for each route.

#### Scenario: Route health check
- **WHEN** deployment completes and a route health check is enabled
- **THEN** the role verifies the expected status and TLS behavior before
  reporting success

#### Scenario: Public admin endpoint
- **WHEN** a client probes an administrative or metrics endpoint not explicitly
  configured as public
- **THEN** the edge denies the request or returns a non-identifying error

#### Scenario: Layered application health
- **WHEN** an integrated application is deployed
- **THEN** its role checks the application directly and performs an HTTPS edge
  check only when Caddy is available and the edge check is enabled
