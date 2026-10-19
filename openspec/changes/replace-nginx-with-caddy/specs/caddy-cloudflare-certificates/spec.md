## Purpose

Provide reliable Cloudflare DNS-01 certificate issuance and renewal for Caddy
routes while keeping the proxy on an upstream image and protecting API
credentials and certificate material.

## ADDED Requirements

### Requirement: Native Cloudflare DNS-01 through approved image
Cloudflare DNS-01 issuance MUST be performed by Caddy using an approved
third-party prebuilt image that includes the Cloudflare DNS module. The
repository MUST NOT maintain a custom Caddy image or build pipeline, and the
global Caddy role MUST own the certificate automation contract.

#### Scenario: Cloudflare certificate requested
- **WHEN** a configured certificate domain requires DNS-01 validation
- **THEN** Caddy uses the supplied Cloudflare credential and stores the
  certificate and key in the managed Caddy data location

#### Scenario: Unapproved image path
- **WHEN** deployment configuration uses an image without the required
  Cloudflare DNS module or uses a repository-owned build
- **THEN** validation rejects the configuration before Caddy starts

### Requirement: Certificate domain mapping
Every TLS route MUST map to a certificate name or an approved Caddy-managed
certificate policy, and the role MUST reject routes whose certificate material
is absent or does not cover the configured hostname before cutover.

#### Scenario: Certificate covers route
- **WHEN** a certificate exists and covers the route hostname
- **THEN** the route is eligible for activation

#### Scenario: Certificate does not cover route
- **WHEN** the certificate is missing, expired beyond the configured grace
  period, or does not cover the hostname
- **THEN** activation fails without exposing the route over an invalid TLS
  configuration

### Requirement: Secret and certificate protection
Cloudflare credentials MUST be supplied through inventory, vault, or an
equivalent secret input, MUST not be written to logs or rendered public
configuration, and MUST be stored with restrictive permissions. Private keys
MUST be readable only by the intended issuer/proxy service identities.

#### Scenario: Secret deployment
- **WHEN** a Cloudflare token is supplied for certificate issuance
- **THEN** the token is written only to a restrictive secret location and is
  omitted from task output and generated public configuration

#### Scenario: Unsafe secret permissions
- **WHEN** the target secret or private-key path is world-readable or writable
- **THEN** validation fails or corrects the mode before the issuer is started

### Requirement: Renewal readiness and handoff
Renewal MUST run before certificate expiry with configurable scheduling and
grace behavior, MUST preserve the last known good certificate on renewal
failure, and MUST reload Caddy only after a complete valid certificate set is
available.

#### Scenario: Successful renewal
- **WHEN** the issuer obtains a renewed certificate and key
- **THEN** the certificate set is atomically made available and Caddy reloads
  without dropping established service unnecessarily

#### Scenario: Failed renewal
- **WHEN** Cloudflare, DNS propagation, or ACME validation fails
- **THEN** the previous valid certificate remains active, failure is observable
  in service logs, and Caddy is not reloaded with incomplete material

### Requirement: Cloudflare scope and propagation controls
The certificate workflow MUST document and validate the required Cloudflare
API token scope and MUST provide configurable DNS propagation wait, retry, and
timeout behavior suitable for DNS-01 issuance.

#### Scenario: Insufficient Cloudflare scope
- **WHEN** the supplied token cannot edit the required zone
- **THEN** issuance fails clearly before any route cutover and does not reveal
  the token value

#### Scenario: Slow DNS propagation
- **WHEN** DNS propagation exceeds the initial wait
- **THEN** the issuer follows the configured retry and timeout policy and leaves
  the existing certificate active until validation succeeds
