# os_edge

**Draft.** Entry VPS for the homelab, IPv6 only: a bare WireGuard server on
the VPS's public IPv6 that OPNsense dials into, an nftables firewall that
answers only SSH from an allowlist, WireGuard and the ICMPv6 that IPv6 needs,
and a CrowdSec agent reporting to the OPNsense LAPI over the tunnel. No
forwarding of public traffic yet.

Only the variable contract exists. The task files are TODOs; see the OpenSpec
change `add-edge-vps-role` for the plan and open questions. The current IPv4
VPS (whole public IPv4 forwarded into WireGuard) is documented there as
`legacy` and has no role path.

## Requirements

- Ansible core 2.17 or newer. No extra collections.
- Target OS still open; `meta/main.yml` lists the skeleton baseline EL 9 and
  EL 10.
- A public IPv6 on the VPS; OPNsense needs working IPv6 upstream.
- Podman (via `os_container`) for the CrowdSec container.

## Keys

The VPS private key is generated on the host and stays there
(`/etc/wireguard/<interface>.key`). The role prints the public key, the
public IPv6, the listen port and the tunnel addresses for the OPNsense peer.
The OPNsense public key comes from `os_edge_wg_peer_public_key`. No secrets
in the repository.

## Role Variables

### defaults/main/00-general.yml

Shared defaults: `storage_base_path` and the `http` retry settings.

### defaults/main/10-edge.yml

| Variable                            | Default                                   | Description                                          |
| ----------------------------------- | ----------------------------------------- | ---------------------------------------------------- |
| `os_edge_ssh_port`                  | `22`                                      | SSH port.                                            |
| `os_edge_ssh_allow`                 | `[]`                                      | Source CIDRs allowed to SSH. Must be set.            |
| `os_edge_wg_interface`              | `wg0`                                     | WireGuard interface name.                            |
| `os_edge_wg_listen_port`            | `51820`                                   | WireGuard listen port (OPNsense dials in).           |
| `os_edge_wg_address`                | `__REQUIRED__`                            | Tunnel address of the VPS, e.g. `10.200.121.2/30`.   |
| `os_edge_wg_peer_address`           | `__REQUIRED__`                            | OPNsense tunnel address.                             |
| `os_edge_wg_peer_public_key`        | `__REQUIRED__`                            | OPNsense public key.                                 |
| `os_edge_wg_peer_allowed_ips_extra` | `[]`                                      | Extra AllowedIPs for the OPNsense peer.              |
| `os_edge_wg_mtu`                    | `1412`                                    | Tunnel MTU (WireGuard over IPv6, OPNsense on PPPoE). |
| `os_edge_crowdsec_enabled`          | `true`                                    | Run the CrowdSec agent.                              |
| `os_edge_crowdsec_image`            | `docker.io/crowdsecurity/crowdsec:v1.8.1` | Pinned CrowdSec image.                               |
| `os_edge_crowdsec_lapi_url`         | `__REQUIRED__`                            | OPNsense LAPI over WireGuard.                        |
| `os_edge_crowdsec_machine_id`       | `__REQUIRED__`                            | Machine name registered on the LAPI.                 |
| `os_edge_crowdsec_machine_password` | `__REQUIRED__`                            | Machine password (vault).                            |
| `os_edge_crowdsec_collections`      | `linux`, `sshd`                           | Hub collections.                                     |
| `os_edge_crowdsec_bouncer_enabled`  | `false`                                   | Host nftables bouncer.                               |
| `os_edge_crowdsec_bouncer_api_key`  | `""`                                      | Bouncer API key (vault).                             |

### vars/main.yml

Derived `app_name` (`edge`), `app_path`, `app_user`, `app_group`.

## Dependencies

None. Run `os_container` first.

## Example Playbook

```yaml
- name: Entry VPS
  hosts: edge_vps
  roles:
    - role: os_edge
```

## License

MIT. See the repository license.

## Author

knelldev
