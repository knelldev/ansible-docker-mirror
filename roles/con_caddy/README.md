# con_caddy

Per-host Caddy reverse proxy, deployed as a rootful Podman Quadlet. It
terminates TLS for the host's apps with Cloudflare DNS-01 wildcard
certificates, proxies to local or LAN upstreams, and adds a static error page,
`robots.txt`/`X-Robots-Tag`, compression, static responses, optional authentik
forward auth, and JSON access logs.

The intended setup: OPNsense forwards a site's SNI by Layer4 passthrough (with
the PROXY protocol) to this host, and this Caddy handles everything above TLS.

## Requirements

- Ansible core 2.17 or newer. No extra collections.
- EL 9 or EL 10 with Podman 4.4 or newer (Quadlet); see `os_container`.
- Ports 80 and 443 free on the host and open in the host firewall. The
  container uses host networking, so nothing else may bind them.
- A Cloudflare API token with `Zone:Read` and `DNS:Edit` on the zones of the
  configured names.

## Role Variables

### defaults/main/00-general.yml

Shared defaults: `storage_base_path` (`/data`) and the `http` retry settings.

### defaults/main/10-caddy.yml

| Variable                           | Default                                         | Description                                                                         |
| ---------------------------------- | ----------------------------------------------- | ----------------------------------------------------------------------------------- |
| `con_caddy_image`                  | `docker.io/caddybuilds/caddy-cloudflare:2.11.7` | Caddy build with the `caddy-dns/cloudflare` module. Needs Caddy 2.11.6 or newer.    |
| `con_caddy_systemd_service_state`  | `started`                                       | `started` or `stopped`. `stopped` renders and validates without starting Caddy.     |
| `con_caddy_acme_email`             | `__REQUIRED__`                                  | ACME account email.                                                                 |
| `con_caddy_cloudflare_api_token`   | `__REQUIRED__`                                  | Cloudflare token. Supply from vault. Written only to `<app_path>/caddy.env` (0600). |
| `con_caddy_cert_wildcards`         | `[]`                                            | Wildcards managed without being served, e.g. `["*.a.knell.dev"]`.                   |
| `con_caddy_proxy_protocol_allow`   | `[]`                                            | CIDRs allowed to send a PROXY header on `:443`. Empty disables it.                  |
| `con_caddy_authentik_outpost_url`  | `""`                                            | authentik outpost base URL for sites with `auth: authentik`.                        |
| `con_caddy_authentik_copy_headers` | authentik identity headers                      | Headers copied from authentik to the upstream.                                      |
| `con_caddy_sites`                  | `[]`                                            | Sites to serve; see below.                                                          |

### vars/main.yml

Derived `app_name` (`caddy`), `app_path` (`/data/caddy`), `app_user`,
`app_group`, and `con_caddy_storage_extra_dirs` (`conf`, `errors`, `data`,
`config`, `logs`).

### Certificates

Caddy 2.10 and newer uses a managed wildcard certificate for every site below
it and requests no per-name certificate. List the wildcards in
`con_caddy_cert_wildcards` so internal names stay out of the public
Certificate Transparency logs. A site name that no wildcard covers, such as
the apex `knell.dev`, gets its own certificate.

### Sites

Each entry in `con_caddy_sites` is shaped like an entry of the migration
repository's `desired/proxy.yaml`:

| Key               | Required                     | Description                                                       |
| ----------------- | ---------------------------- | ----------------------------------------------------------------- |
| `name`            | yes                          | Site name, e.g. `app.a.knell.dev`. Unique across all sites.       |
| `aliases`         | no                           | More names for the same site.                                     |
| `upstream`        | yes, unless `redirect` given | URL or list of URLs, e.g. `http://127.0.0.1:8080`.                |
| `upstream_tls`    | no                           | `skip_verify` for an upstream with a self-signed certificate.     |
| `lb_policy`       | no                           | Caddy `lb_policy` for a list of upstreams, e.g. `ip_hash`.        |
| `noindex`         | no                           | `true` serves `robots.txt` with `Disallow: /` and `X-Robots-Tag`. |
| `headers_down`    | no                           | Dict of response headers to set.                                  |
| `auth`            | no                           | `authentik` enables forward auth through the outpost.             |
| `auth_skip_paths` | no                           | Caddy path patterns that bypass forward auth, e.g. `/api/*`.      |
| `block_paths`     | no                           | Caddy path patterns answered with 404, e.g. `/if/admin*`.         |
| `responses`       | no                           | List of `{path, body, content_type, status}` static replies.      |
| `redirect`        | no                           | Redirect target for every request not matched by `responses`.     |

Every site gets `encode zstd gzip`, JSON access logs in
`<app_path>/logs/access.log` (for CrowdSec), and the static error page for
upstream errors 502, 503 and 504. Caddy redirects HTTP to HTTPS.

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
        con_caddy_acme_email: admin@knell.dev
        con_caddy_cloudflare_api_token: "{{ vault_cloudflare_dns_token }}"
        con_caddy_cert_wildcards: ["*.knell.dev"]
        con_caddy_proxy_protocol_allow: ["10.0.10.1/32"]
        con_caddy_authentik_outpost_url: http://10.0.10.7:9000
        con_caddy_sites:
          - name: home.knell.dev
            upstream: http://127.0.0.1:8080
            noindex: true
            auth: authentik
            auth_skip_paths: ["/api/*"]
          - name: auth.knell.dev
            upstream: http://127.0.0.1:9000
            noindex: true
            block_paths: ["/if/admin*"]
```

Run it with `ansible-playbook playbooks/con_caddy.yml -i <inventory>`.

## License

MIT. See the repository license.

## Author

knelldev
