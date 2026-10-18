# con_caddy

Per-host Caddy reverse proxy, deployed as a rootful Podman Quadlet. It
terminates TLS for the host's apps with Cloudflare DNS-01 wildcard
certificates or HTTP-01, proxies to local, LAN or container-name upstreams,
and adds a static error page, `robots.txt`/`X-Robots-Tag`, compression,
static responses, optional forward auth (authentik, Authelia, oauth2-proxy and
others), free-form Caddyfile extras, and JSON access logs.

The intended setup: OPNsense forwards a site's SNI by Layer4 passthrough (with
the PROXY protocol) to this host, and this Caddy handles everything above TLS.

## Requirements

- Ansible core 2.17 or newer. No extra collections.
- EL 9 or EL 10 with Podman 4.4 or newer (Quadlet); see `os_container`.
- Ports 80 and 443 free on the host and open in the host firewall. The
  container uses host networking (or publishes both ports), so nothing else
  may bind them.
- For DNS-01: a Cloudflare API token with `Zone:Read` and `DNS:Edit` on the
  zones of the configured names. For HTTP-01: ports 80/443 reachable from the
  internet for the site names.

## Role Variables

### defaults/main/00-general.yml

Shared defaults: `storage_base_path` (`/data`) and the `http` retry settings.

### defaults/main/10-caddy.yml

| Variable                           | Default                                         | Description                                                                                         |
| ---------------------------------- | ----------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `con_caddy_image`                  | `docker.io/caddybuilds/caddy-cloudflare:2.11.7` | Caddy build with the `caddy-dns/cloudflare` module. Needs Caddy 2.11.6 or newer.                    |
| `con_caddy_systemd_service_state`  | `started`                                       | `started` or `stopped`. `stopped` renders and validates without starting Caddy.                     |
| `con_caddy_acme_email`             | `__REQUIRED__`                                  | ACME account email.                                                                                 |
| `con_caddy_acme_challenge`         | `dns`                                           | Default ACME challenge: `dns` (Cloudflare DNS-01) or `http` (HTTP-01/TLS-ALPN-01).                  |
| `con_caddy_cloudflare_api_token`   | `""`                                            | Cloudflare token; required when any site uses `dns`. Supply from vault. Only in `caddy.env` (0600). |
| `con_caddy_cert_wildcards`         | `[]`                                            | Wildcards managed without being served, e.g. `["*.example.com"]`. Needs `dns`.                      |
| `con_caddy_proxy_protocol_allow`   | `[]`                                            | CIDRs allowed to send a PROXY header on `:443`. Empty disables it.                                  |
| `con_caddy_networks`               | `[]`                                            | Podman networks to join for container-name upstreams. Empty keeps host networking.                  |
| `con_caddy_global_options_extra`   | `""`                                            | Raw Caddyfile lines added to the global options block.                                              |
| `con_caddy_extra_config`           | `""`                                            | Raw top-level Caddyfile content (snippets, extra site blocks), placed before the sites.             |
| `con_caddy_forward_auth`           | `{}`                                            | Forward auth providers by name; see below. Adds to or replaces the built-in `authentik`.            |
| `con_caddy_authentik_outpost_url`  | `""`                                            | authentik outpost base URL for the built-in `authentik` provider.                                   |
| `con_caddy_authentik_copy_headers` | authentik identity headers                      | Headers copied from authentik to the upstream.                                                      |
| `con_caddy_sites`                  | `[]`                                            | Sites to serve; see below.                                                                          |

### vars/main.yml

Derived `app_name` (`caddy`), `app_path` (`/data/caddy`), `app_user`,
`app_group`, `con_caddy_storage_extra_dirs` (`conf`, `errors`, `data`,
`config`, `logs`), `con_caddy_forward_auth_all` (the built-in `authentik`
provider merged with `con_caddy_forward_auth`) and `con_caddy_dns_used`.

### Certificates

Caddy 2.10 and newer uses a managed wildcard certificate for every site below
it and requests no per-name certificate. List the wildcards in
`con_caddy_cert_wildcards` so internal names stay out of the public
Certificate Transparency logs. A site name that no wildcard covers, such as
the apex `example.com`, gets its own certificate.

`con_caddy_acme_challenge` sets the default challenge; a site's
`acme_challenge` overrides it. With `dns` the default issuers (Let's Encrypt,
then ZeroSSL) use Cloudflare DNS-01, and an `http` site gets its own issuers
with HTTP-01/TLS-ALPN-01, for names without a Cloudflare zone. With `http`
no Cloudflare token is needed unless a site sets `acme_challenge: dns`;
wildcards need `dns`. Give `http` sites names outside the wildcards, or they
get their own certificate.

### Networking

By default Caddy uses host networking: it binds 80/443 directly, sees client
addresses and reaches upstreams on `127.0.0.1` and the LAN. Podman cannot
combine host networking with other networks, so a non-empty
`con_caddy_networks` switches Caddy to those networks and publishes `80/tcp`,
`443/tcp` and `443/udp` instead. Upstreams then use container names, e.g.
`http://gitlab:80`; `127.0.0.1` means the Caddy container itself, so host-only
upstreams need the host's LAN address or `host.containers.internal`. Rootful
port forwarding keeps client source addresses, so the PROXY protocol allow
list still applies. Write `<name>.network` for a Quadlet-managed network (the
`con_*` roles create `<app>_default.network`), so systemd starts it first; a
plain name joins an existing network as is.

### Forward auth

A site's `auth` names a provider from `con_caddy_forward_auth_all`. The
built-in `authentik` provider uses `con_caddy_authentik_outpost_url` and
`con_caddy_authentik_copy_headers`. Keys per provider in
`con_caddy_forward_auth`:

| Key            | Required | Description                                                                 |
| -------------- | -------- | --------------------------------------------------------------------------- |
| `url`          | yes      | Provider base URL, e.g. `http://authelia:9091`.                             |
| `uri`          | yes      | Auth endpoint path on the provider, e.g. `/api/authz/forward-auth`.         |
| `copy_headers` | no       | Response headers copied to the upstream, e.g. `Remote-User`.                |
| `proxy_paths`  | no       | Path patterns proxied to the provider without auth, e.g. `/oauth2/*`.       |
| `extra_config` | no       | Raw lines inside the `forward_auth` block, e.g. a `handle_response` on 401. |

```yaml
con_caddy_forward_auth:
  authelia:
    url: http://authelia:9091
    uri: /api/authz/forward-auth
    copy_headers: [Remote-User, Remote-Groups, Remote-Email, Remote-Name]
  oauth2:
    url: http://oauth2-proxy:4180
    uri: /oauth2/auth
    copy_headers: [X-Auth-Request-User, X-Auth-Request-Email]
    proxy_paths: ["/oauth2/*"]
    extra_config: |
      @unauthorized status 401
      handle_response @unauthorized {
        redir * /oauth2/sign_in?rd={scheme}://{host}{uri}
      }
```

### Sites

Each entry in `con_caddy_sites` is shaped like an entry of the migration
repository's `desired/proxy.yaml`:

| Key                  | Required                     | Description                                                       |
| -------------------- | ---------------------------- | ----------------------------------------------------------------- |
| `name`               | yes                          | Site name, e.g. `app.example.com`. Unique across all sites.       |
| `aliases`            | no                           | More names for the same site.                                     |
| `upstream`           | yes, unless `redirect` given | URL or list of URLs, e.g. `http://127.0.0.1:8080`.                |
| `upstream_tls`       | no                           | `skip_verify` for an upstream with a self-signed certificate.     |
| `lb_policy`          | no                           | Caddy `lb_policy` for a list of upstreams, e.g. `ip_hash`.        |
| `noindex`            | no                           | `true` serves `robots.txt` with `Disallow: /` and `X-Robots-Tag`. |
| `headers_down`       | no                           | Dict of response headers to set.                                  |
| `auth`               | no                           | Forward auth provider name, e.g. `authentik`.                     |
| `auth_skip_paths`    | no                           | Caddy path patterns that bypass forward auth, e.g. `/api/*`.      |
| `block_paths`        | no                           | Caddy path patterns answered with 404, e.g. `/if/admin*`.         |
| `responses`          | no                           | List of `{path, body, content_type, status}` static replies.      |
| `redirect`           | no                           | Redirect target for every request not matched by `responses`.     |
| `acme_challenge`     | no                           | `dns` or `http`; overrides `con_caddy_acme_challenge`.            |
| `extra_config`       | no                           | Raw Caddyfile lines inside the site block, e.g. `request_body`.   |
| `proxy_extra_config` | no                           | Raw lines inside the `reverse_proxy` block, e.g. `header_up`.     |

Every site gets `encode zstd gzip`, JSON access logs in
`<app_path>/logs/access.log` (for CrowdSec), and the static error page for
upstream errors 502, 503 and 504. Caddy redirects HTTP to HTTPS. The
`extra_config` keys are an escape hatch: their lines go into the Caddyfile
unchanged (indented), and the validate step below catches syntax errors.

The Caddyfile is validated with the pinned image before it replaces the
active one, then Caddy reloads. A changed image, token or Quadlet restarts it.

## Dependencies

None. Run `os_container` first on a fresh host.

## Example Playbook

```yaml
- name: Caddy on an app host
  hosts: app_hosts
  roles:
    - role: con_caddy
      vars:
        con_caddy_acme_email: admin@example.com
        con_caddy_cloudflare_api_token: "{{ vault_cloudflare_dns_token }}"
        con_caddy_cert_wildcards: ["*.example.com"]
        con_caddy_proxy_protocol_allow: ["192.0.2.1/32"]
        con_caddy_authentik_outpost_url: http://192.0.2.7:9000
        con_caddy_sites:
          - name: home.example.com
            upstream: http://127.0.0.1:8080
            noindex: true
            auth: authentik
            auth_skip_paths: ["/api/*"]
          - name: auth.example.com
            upstream: http://127.0.0.1:9000
            noindex: true
            block_paths: ["/if/admin*"]
          - name: www.example.org
            upstream: http://127.0.0.1:8081
            acme_challenge: http
            extra_config: |
              request_body {
                max_size 100MB
              }
            proxy_extra_config: |
              header_up X-Forwarded-Ssl on
```

With container-name upstreams instead of host networking:

```yaml
con_caddy_networks: ["gitlab_default.network"]
con_caddy_sites:
  - name: gitlab.example.com
    upstream: http://gitlab:80
```

Run it with `ansible-playbook playbooks/con_caddy.yml -i <inventory>`.

## License

MIT. See the repository license.

## Author

knelldev
