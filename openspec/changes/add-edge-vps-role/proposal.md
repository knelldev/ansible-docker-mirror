## Why

Public homelab apps enter through a VPS (no static IP at home). The migration
repo (`lab_01_migrations`, change `edge-vps-geodns`) wants every entry VPS
rebuildable from code, and more than one of them later (Spain, Germany).
Today the VPS forwards its whole public IPv4 over WireGuard to OPNsense, which
keeps client addresses for Caddy, authentik and CrowdSec.

## What Changes

- Add `roles/os_edge/` and `playbooks/os_edge.yml` for an entry VPS:
  - WireGuard tunnel to OPNsense (VPS listens, OPNsense dials in).
  - All traffic for the public IPv4 routed into the tunnel without SNAT,
    except what the VPS answers itself (SSH, WireGuard).
  - nftables firewall: SSH only from an allowlist.
  - CrowdSec agent in a Podman Quadlet (sshd and linux collections),
    registered as a machine on the OPNsense LAPI over WireGuard; optional
    host nftables bouncer.
- This first step adds only the skeleton and the variable contract; tasks are
  TODOs until the blockers below are resolved.

## Capabilities

### New Capabilities

- `edge-vps`: entry VPS forwarding its public IPv4 to OPNsense with a minimal
  firewall and CrowdSec reporting.

### Modified Capabilities

- None.

## Impact

- New role, playbook, role README/AGENTS, `roles/AGENTS.md` index.
- External: OPNsense WireGuard peer and CrowdSec LAPI machine registration.
- Separate from `os_vps` and `specify-os-vps-role` (generic VPS tuning).

## Alternatives And Risks

- DNAT per port on the VPS: simpler rules, but every new port needs a change
  and scans on other ports stay invisible to OPNsense's CrowdSec.
- PROXY protocol from a VPS proxy: keeps client IPs only for HTTP/TLS, not for
  game or other TCP/UDP ports.
- CrowdSec as a host package: fewer moving parts on a tiny VPS, but splits
  from the repository's container model; decide in E-Q3 follow-up.
- Risk: firewall or routing mistakes lock out SSH. Mitigation: non-empty
  allowlist enforced, `nft -c` check, timed rollback.

Approval status: skeleton and plan approved by the user on 2026-10-17
("start caddy/vps as podman"). Task implementation needs a separate approval
after the blockers in `tasks.md` are resolved.
