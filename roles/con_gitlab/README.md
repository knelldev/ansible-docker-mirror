# con_gitlab

GitLab (Linux package image, CE or EE) deployed as a rootful Podman Quadlet.
The role renders `gitlab.rb` from variables, starts the container, waits until
GitLab answers, and applies admin settings through a post-reconfigure script.

The intended setup: a reverse proxy (for example `con_caddy`) terminates TLS in
front of GitLab, and GitLab's bundled nginx serves plain HTTP behind it. Each
addon (registry, pages, KAS, SMTP, LDAP, SAML, Let's Encrypt) is off or at
GitLab's default unless you set its variables.

## Requirements

- Ansible core 2.17 or newer. No extra collections.
- EL 9 or EL 10 with Podman 4.4 or newer (Quadlet); see `os_container`.
- Host ports 80/443 (when `con_gitlab_expose`), the SSH publish port and, with
  a dedicated KAS name, the KAS port free on the host.

## Role Variables

Defaults live in `defaults/main/*.yml`; every `con_gitlab_*` key there is
documented inline. The ones you set most often:

### Container and URLs (`10-gitlab.yml`)

| Variable                            | Default                            | Description                                                                 |
| ----------------------------------- | ---------------------------------- | --------------------------------------------------------------------------- |
| `con_gitlab_edition`                | `gitlab-ee`                        | `gitlab-ee` or `gitlab-ce`.                                                 |
| `con_gitlab_version`                | `latest`                           | Image tag, e.g. `18.5.1-ee.0`.                                              |
| `con_gitlab_base_domain`            | `example.com`                      | Base for the default names below.                                           |
| `con_gitlab_domain`                 | `gitlab.<base_domain>`             | GitLab's host name.                                                         |
| `con_gitlab_external_url`           | `http://<domain>/`                 | Use `https://` when a proxy terminates TLS in front, so links are correct.  |
| `con_gitlab_expose`                 | `true`                             | Publish ports 80 and 443.                                                   |
| `con_gitlab_rb_custom`              | comment                            | Free-form `gitlab.rb` lines for anything without a variable.                |

### SSH

| Variable                            | Default                     | Description                                                              |
| ----------------------------------- | --------------------------- | ------------------------------------------------------------------------ |
| `con_gitlab_shell_ssh_port`         | `2022`                      | Port shown in clone URLs: the one clients connect to.                    |
| `con_gitlab_shell_ssh_publish_port` | `con_gitlab_shell_ssh_port` | Host port mapped to the container's 22. Differs when a firewall forwards. |
| `con_gitlab_shell_ssh_host`         | `""`                        | SSH host name in clone URLs. Empty: the `external_url` host.             |

### Bundled nginx and certificates (`10-gitlab.yml`, `20-gitlab-ssl.yml`)

| Variable                                     | Default | Description                                                          |
| -------------------------------------------- | ------- | -------------------------------------------------------------------- |
| `con_gitlab_nginx_listen_https`              | `nil`   | `false` behind a TLS-terminating proxy with an `https` external URL. |
| `con_gitlab_nginx_listen_port`               | `nil`   | nginx port; `80` with the setting above.                             |
| `con_gitlab_nginx_redirect_http_to_https`    | `false` | Let GitLab's nginx redirect to HTTPS.                                |
| `con_gitlab_nginx_real_ip_trusted_addresses` | `[]`    | Proxy addresses, so logs and rate limits see client IPs.             |
| `con_gitlab_nginx_real_ip_header`            | `""`    | e.g. `X-Forwarded-For`.                                              |
| `con_gitlab_nginx_real_ip_recursive`         | `""`    | e.g. `on`.                                                           |
| `con_gitlab_nginx_ssl_certificate`(`_key`)   | `""`    | Own certificate paths in the container. Empty: GitLab's default.     |
| `con_gitlab_letsencrypt_enable`              | `false` | GitLab's built-in Let's Encrypt (only without a TLS proxy in front). |
| `con_gitlab_letsencrypt_auto_renew`          | `true`  | Renewal for the above.                                               |

### Registry, Pages, KAS

| Variable                            | Default                     | Description                                                                         |
| ----------------------------------- | --------------------------- | ----------------------------------------------------------------------------------- |
| `con_gitlab_registry_enable`        | `false`                     | Container registry at `con_gitlab_registry_external_url` (`registry.<base_domain>`). |
| `con_gitlab_pages_enable`           | `false`                     | Pages at `con_gitlab_pages_external_url` (`pages.<base_domain>`).                   |
| `con_gitlab_kas_enable`             | `true`                      | KAS, the server for the GitLab agent for Kubernetes (GitLab's default).             |
| `con_gitlab_kas_external_url`       | `""`                        | Empty: agents use `/-/kubernetes-agent/` on the GitLab domain. Or an own name.      |
| `con_gitlab_kas_port`               | `8150`                      | Host port for KAS with an own name.                                                 |
| `con_gitlab_kas_expose`             | true with an own name       | Publish the KAS agent port.                                                         |

### Mail, sign-in, admin settings

SMTP and sender: `11-gitlab-smtp.yml` (`con_gitlab_smtp_*`, `con_gitlab_email_*`).
LDAP and SAML/OmniAuth (authentik example): `12-gitlab-auth.yml`.
Sign-up, group creation, admin mode, 2FA, import sources, Service Ping
(`con_gitlab_usage_metrics`) and free-form Rails settings
(`con_gitlab_config_custom`): `30-gitlab-config.yml`, applied by
`post-reconfigure.sh` after each reconfigure.

## KAS (GitLab agent for Kubernetes)

Agents in a cluster only connect out to KAS; the cluster needs no inbound rule.
KAS's internal API (8153) stays inside the container.

- **Path mode (default):** agents use `wss://<gitlab domain>/-/kubernetes-agent/`
  through the existing site. Nothing else to set.
- **Own name:** set `con_gitlab_kas_external_url`, e.g.
  `wss://kas.{{ con_gitlab_base_domain }}/`. The role publishes
  `con_gitlab_kas_port` and your proxy forwards that name (WebSocket) to it.
  The Kubernetes API proxy for user access and the dashboard stays on the
  GitLab domain, where GitLab sets its login cookie.

Free on self-managed: GitOps with Flux, CI/CD access to the cluster, user
access and the Kubernetes dashboard.

## Dependencies

None. Run `os_container` first on a fresh host.

## Example Playbook

GitLab behind a TLS proxy, with SSH forwarded from 22 and KAS on its own name:

```yaml
- name: GitLab
  hosts: gitlab_hosts
  roles:
    - role: con_gitlab
      vars:
        con_gitlab_version: 18.5.1-ee.0
        con_gitlab_base_domain: example.com
        con_gitlab_external_url: "https://gitlab.example.com/"
        con_gitlab_nginx_listen_https: false
        con_gitlab_nginx_listen_port: 80
        con_gitlab_nginx_real_ip_trusted_addresses: ["10.0.10.0/24"]
        con_gitlab_nginx_real_ip_header: X-Forwarded-For
        con_gitlab_nginx_real_ip_recursive: "on"
        con_gitlab_shell_ssh_port: 22
        con_gitlab_shell_ssh_publish_port: 2022
        con_gitlab_kas_external_url: "wss://kas.example.com/"
```

Run it with `ansible-playbook playbooks/con_gitlab.yml -i <inventory>`.

## License

MIT. See the repository license.

## Author

knelldev
