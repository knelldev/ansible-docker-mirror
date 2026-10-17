## ADDED Requirements

### Requirement: Validated configuration

The role SHALL validate the rendered Caddyfile with the configured image before
it replaces the active Caddyfile, and SHALL reject invalid site definitions
before any change on the host.

#### Scenario: Invalid Caddyfile

- **WHEN** the rendered Caddyfile fails `caddy validate`
- **THEN** the role fails and the active Caddyfile stays unchanged

#### Scenario: Duplicate site name

- **WHEN** two sites or aliases share a name
- **THEN** the role fails before writing files

### Requirement: Wildcard DNS-01 certificates

The role SHALL obtain certificates through the Cloudflare DNS-01 challenge and
SHALL manage each configured wildcard without serving it, so covered sites use
the wildcard instead of a per-name certificate.

#### Scenario: Site under a wildcard

- **WHEN** `*.a.knell.dev` is configured and a site `app.a.knell.dev` exists
- **THEN** the rendered configuration automates only `*.a.knell.dev` for it

### Requirement: Secret handling

The Cloudflare token SHALL come from a variable and SHALL be written only to a
root-owned 0600 environment file, never to the Caddyfile or task output.

#### Scenario: Token deployment

- **WHEN** the role writes the token
- **THEN** the task output hides it and the Caddyfile references only the
  environment variable

### Requirement: Site behavior

Each site SHALL proxy to its upstream (or redirect), compress responses, write
JSON access logs, and answer upstream errors 502, 503 and 504 with the static
error page. Optional per-site settings SHALL add `robots.txt` and
`X-Robots-Tag`, response headers, 404 for blocked paths, static responses, and
authentik forward auth with skip paths.

#### Scenario: Upstream down

- **WHEN** the upstream refuses connections
- **THEN** the client receives the static error page with status 502

#### Scenario: Forward auth skip path

- **WHEN** a site has `auth: authentik` and `auth_skip_paths: ["/api/*"]`
- **THEN** requests to `/api/*` reach the upstream without forward auth and
  all other requests go through the authentik outpost first

### Requirement: Stoppable install

The role SHALL render and validate everything with the service state set to
`stopped`, without starting Caddy.

#### Scenario: Install without start

- **WHEN** `con_caddy_systemd_service_state` is `stopped`
- **THEN** files and the Quadlet exist, the Caddyfile is validated, and Caddy
  is not running
