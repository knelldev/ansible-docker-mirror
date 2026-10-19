## 1. Resolve implementation gates

- [ ] 1.1 Select and approve the third-party Caddy image repository, maintainer, tag/digest policy, provenance, and Cloudflare DNS module verification evidence; **BLOCKER** before deployment work.
- [ ] 1.2 Confirm the target Caddy version/directive set, rootless Podman networking assumptions, and supported host OS/runtime against `TECHSTACK.md` and controlled-host evidence.
- [ ] 1.3 Define the migration inventory contract for private networks, route upstreams, certificate domains, Authentik endpoint, Cloudflare token source, and rollback listener ownership.
- [ ] 1.4 Define the app integration contract: opt-in variable, fragment filename ownership, shared network membership, optional auth block, fragment removal, and direct-versus-edge health checks.

## 2. Create role and deployment skeleton

- [ ] 2.1 Add `roles/con_caddy/` with the repository-required defaults, tasks, vars, meta, templates, files, README, and role-level DOX contract.
- [ ] 2.2 Add `playbooks/con_caddy.yml` using the standard host limit and role invocation conventions.
- [ ] 2.3 Define role-prefixed defaults for image reference, service state, storage paths, published ports, private networks, route list, logging, health checks, and security policy.
- [ ] 2.4 Render rootless Podman Quadlet units for Caddy and explicitly declared private network attachments without publishing application ports.
- [ ] 2.5 Configure restrictive ownership and permissions for Caddy data/config directories, Cloudflare credentials, and certificate/private-key material.
- [ ] 2.6 Make the global Caddy role valid with zero app fragments and independent of all application services; create the controlled `sites-enabled/` import directory.
- [ ] 2.7 Separate installation/configuration validation from startup with explicit service enabled/state variables; permit a validated but stopped edge.

## 3. Implement route rendering and validation

- [ ] 3.1 Define and validate the typed route schema, including hostname/path identity, upstream, network, certificate reference, transport options, and supported methods.
- [ ] 3.2 Reject duplicate route identities, malformed or unsafe upstreams, undeclared networks, missing certificates, and unsupported option combinations before service changes.
- [ ] 3.3 Render deterministic Caddy configuration with HTTPS redirect, modern TLS defaults, controlled forwarding headers, no public admin endpoint, and configurable HSTS readiness.
- [ ] 3.4 Render per-route Authentik forward-auth behavior with protected upstream access, explicit callback/outpost handling, and controlled identity headers.
- [ ] 3.5 Render per-route CORS only when explicitly configured; validate origins, credentials, methods, headers, preflight behavior, and wildcard restrictions.
- [ ] 3.6 Add the managed non-disclosing error page, robots/noindex behavior where required, and configured gateway/error handling without request-variable leakage.
- [ ] 3.7 Add structured access/error logging and configurable route health checks through the rootless service path.
- [ ] 3.8 Add the shared app fragment template/validation boundary and reject duplicate hostname/path identities across all assembled fragments.
- [ ] 3.9 Add the shared reload operation/handler: validate the complete assembled configuration, reload only on success, and preserve the active configuration on failure.
- [ ] 3.10 Make the shared reload operation safe when Caddy is stopped and prevent app roles from implicitly starting or hard-requiring Caddy.

## 4. Implement Cloudflare DNS-01 automation

- [ ] 4.1 Configure native Caddy DNS-01 automation using the approved third-party Cloudflare-enabled image and document the required Cloudflare zone/token scope.
- [ ] 4.2 Store the Cloudflare credential through vault/inventory input without exposing it in logs or public rendered configuration.
- [ ] 4.3 Configure DNS propagation wait, retry, timeout, renewal scheduling, certificate storage, and last-known-good behavior.
- [ ] 4.4 Verify certificate hostname coverage and complete certificate/key readiness before exposing each TLS route.
- [ ] 4.5 Reload Caddy only after successful certificate issuance or renewal and valid complete material; preserve the previous certificate on failure.

## 5. Add configuration safety and migration controls

- [ ] 5.1 Validate the rendered Caddy configuration with the selected image before activation and preserve the running configuration when validation fails.
- [ ] 5.2 Make reruns idempotent and restart/reload only when effective configuration, image, certificate, or relevant service inputs change.
- [ ] 5.3 Define role-order behavior for Caddy-first, app-first, app-only, and route-free deployments; avoid hard `Requires=` dependencies from Caddy to applications.
- [ ] 5.4 Document deployment prerequisites, route variable examples, Authentik setup, Cloudflare setup, private-network topology, logs, health checks, and known limitations in the role README.
- [ ] 5.5 Document side-by-side validation, 80/443 cutover, smoke-test checklist, and rollback to `con_nginx`; do not remove or modify Nginx in this change.

## 6. Verify before cutover

- [ ] 6.1 Add or run YAML, ansible-lint, syntax, and role validation checks for the new role/playbook.
- [ ] 6.2 Test private upstream reachability and confirm application ports are absent from host bindings.
- [ ] 6.3 Test TLS redirect, certificate coverage, security headers, error responses, logs, and no public admin endpoint.
- [ ] 6.4 Test Authentik unauthenticated redirect/deny, authenticated proxying, callback path, cookies, and identity header handling.
- [ ] 6.5 Test allowed and denied CORS preflight/origin cases, including credentials and wildcard rejection.
- [ ] 6.6 Test Cloudflare DNS-01 issuance, slow propagation, renewal, failed renewal retention, and safe Caddy reload in a controlled environment.
- [ ] 6.7 Record verification evidence and explicitly request approval before any production listener cutover or Nginx retirement.
- [ ] 6.8 Pilot one application role integration, then verify app-first, Caddy-first, app-only, fragment removal, invalid-fragment rollback, and post-deploy edge health behavior.
