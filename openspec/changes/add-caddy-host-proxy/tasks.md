## Status

- Approval: approved 2026-10-17 for implementation on `feature/caddy-edge`;
  live deployment not approved.
- Plan state: implemented, not deployed.
- Blocker: none for the code; a live test needs an app host and a Cloudflare
  token.

## 1. Role

- [x] 1.1 Generate `roles/con_caddy/` from the role skeleton; add defaults,
      vars, handlers, templates, error page, README, AGENTS.
- [x] 1.2 Add `playbooks/con_caddy.yml`.
- [x] 1.3 Render the Caddyfile from `con_caddy_sites` with wildcard DNS-01,
      optional PROXY protocol, forward auth, robots, blocked paths, static
      responses and redirects.
- [x] 1.4 Validate inputs (asserts) and the Caddyfile (`template` `validate`
      with the pinned image).
- [x] 1.5 Update `roles/AGENTS.md` index and the root README playbook list.

## 2. Verification

- [x] 2.1 `ansible-lint` (production) and `yamllint` on the role and playbook.
- [x] 2.2 `ansible-playbook --syntax-check playbooks/con_caddy.yml`.
- [x] 2.3 Render an example site list shaped like `desired/proxy.yaml` and run
      `caddy validate` and `caddy fmt` with the pinned image.
- [x] 2.4 Run the input asserts with valid, missing-outpost and duplicate-name
      input.
- [ ] 2.5 Live test on one app host: start, certificate issuance, reload,
      error page, forward auth, PROXY protocol from OPNsense.

## 3. Parity with con_nginx (requested 2026-10-18)

Scope note: `con_caddy_networks` only joins existing networks on request; the
role still owns no shared proxy network, so the scope boundary holds.

- [x] 3.1 Free-form Caddyfile: site `extra_config`, `proxy_extra_config`,
      `con_caddy_global_options_extra`, `con_caddy_extra_config`.
- [x] 3.2 Optional Podman networks (`con_caddy_networks`) replacing host
      networking, with published 80/443 (Podman rejects host plus others).
- [x] 3.3 Generic forward auth providers (`con_caddy_forward_auth`), authentik
      kept as a built-in preset with the old variables.
- [x] 3.4 HTTP-01 as default or per site (`acme_challenge`); Cloudflare token
      required only when DNS-01 is used.
- [x] 3.5 Mark `con_nginx` deprecated.

## Verification Evidence

- 2026-10-18: four rendered scenarios (legacy, all features, HTTP-01 default,
  HTTP-01 default with one DNS-01 site) pass `caddy validate`
  (`caddybuilds/caddy-cloudflare:2.11.7`). The legacy scenario adapts to JSON
  identical to the previous template. Negative asserts fail as expected
  (wildcards with http, missing token, unknown provider, authentik without
  URL, bad challenge). `ansible-lint` 0 failures, `yamllint` and `prettier`
  clean. Quadlet with networks and PROXY protocol in bridge mode not tested
  on a live host.

- 2026-10-17: `ansible-lint roles/con_caddy playbooks/con_caddy.yml`: 0
  failures, production profile. `yamllint`: clean. Syntax check: pass.
- 2026-10-17: rendered example with five sites: `Valid configuration`,
  `caddy fmt` diff empty (`caddybuilds/caddy-cloudflare:2.11.7`).
- 2026-10-17: asserts pass for the example, fail for a missing outpost URL and
  for a duplicate alias.

## Next Action

- Decide whether `replace-nginx-with-caddy` is narrowed to this slice or
  closed, then run 2.5 on one app host.
