# os_wg

**Draft.** Bare WireGuard endpoint: one interface with one peer that dials
in (for an entry VPS: OPNsense over the VPS's public IPv6), and an optional
edge part that turns on IPv4/IPv6 forwarding (`os_wg_edge_enabled`, default
off). The VPS baseline is `os_prepare` (with its optional nftables
allowlist) plus `os_wg`.

Only the variable contract exists. The task files are TODOs; see the OpenSpec
change `add-edge-vps-role` for the plan and open questions.

## Requirements

- Ansible core 2.17 or newer. No extra collections.
- Target OS still open; `meta/main.yml` lists the skeleton baseline EL 9 and
  EL 10.
- For an entry VPS: a public IPv6; OPNsense needs working IPv6 upstream.

## Keys

The private key is generated on the host and stays there
(`/etc/wireguard/<interface>.key`). The role prints the public key, the
public IPv6, the listen port and the tunnel addresses for the peer. The
peer's public key comes from `os_wg_peer_public_key`. No secrets in the
repository.

## Role Variables

### defaults/main/00-general.yml

Shared defaults: `storage_base_path` and the `http` retry settings.

### defaults/main/10-wg.yml

| Variable                       | Default        | Description                                           |
| ------------------------------ | -------------- | ----------------------------------------------------- |
| `os_wg_interface`              | `wg0`          | WireGuard interface name.                             |
| `os_wg_listen_port`            | `51820`        | Listen port (the peer dials in).                      |
| `os_wg_address`                | `__REQUIRED__` | Own tunnel address, e.g. `10.200.121.2/30`.           |
| `os_wg_peer_address`           | `__REQUIRED__` | Peer tunnel address.                                  |
| `os_wg_peer_public_key`        | `__REQUIRED__` | Peer public key.                                      |
| `os_wg_peer_allowed_ips_extra` | `[]`           | Extra AllowedIPs for the peer.                        |
| `os_wg_mtu`                    | `1412`         | Tunnel MTU (WireGuard over IPv6, peer on PPPoE).      |
| `os_wg_edge_enabled`           | `false`        | Edge part: forwarding between public side and tunnel. |
| `os_wg_edge_ipv4_forward`      | `true`         | IPv4 forwarding when the edge part is on.             |
| `os_wg_edge_ipv6_forward`      | `true`         | IPv6 forwarding when the edge part is on.             |

### vars/main.yml

The shared `app_*` lines; the role stores nothing under `app_path`.

## Dependencies

None. Run `os_prepare` first.

## Example Playbook

```yaml
- name: Entry VPS
  hosts: edge_vps
  roles:
    - role: os_prepare
    - role: os_wg
      vars:
        os_wg_edge_enabled: true
```

## License

MIT. See the repository license.

## Author

knelldev
