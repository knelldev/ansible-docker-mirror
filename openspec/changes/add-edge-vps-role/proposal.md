## Why

Public homelab apps enter through a VPS (no static IP at home). The migration
repo (`lab_01_migrations`, change `edge-vps-geodns`) wants every entry VPS
rebuildable from code, and more than one of them later (Spain, Germany).
New VPSes are IPv6 only (no paid IPv4), so the first job of the role is a
WireGuard endpoint on IPv6 that OPNsense can dial into.

## What Changes

- Add `roles/os_wg/` and `playbooks/os_wg.yml` for an entry VPS:
  - Bare WireGuard server on the VPS's public IPv6; OPNsense dials in.
  - VPS private key generated on the host; the role prints what OPNsense
    needs (public IPv6, port, public key, tunnel addresses).
  - nftables firewall: SSH only from an allowlist (and over the tunnel), the
    WireGuard port, ICMPv6 for neighbour discovery and PMTU.
  - CrowdSec agent in a Podman Quadlet (sshd and linux collections),
    registered as a machine on the OPNsense LAPI over WireGuard; optional
    host nftables bouncer.
- Not in this version: forwarding or DNAT of public traffic into the tunnel
  (follow-up `os_wg_edge (forwarding rules)`).
- The current IPv4 VPS (whole public IPv4 routed to the VPS and forwarded
  into WireGuard) stays as it is: documented as `legacy`, no role path.
- This step adds only the skeleton and the variable contract; tasks are TODOs
  until the blockers in `tasks.md` are resolved.

## Capabilities

### New Capabilities

- `edge-vps`: IPv6-only entry VPS with a WireGuard endpoint for OPNsense, a
  minimal firewall and CrowdSec reporting.

### Modified Capabilities

- None.

## Impact

- New role, playbook, role README/AGENTS, `roles/AGENTS.md` index.
- External: OPNsense WireGuard peer (client side, PersistentKeepalive) and
  CrowdSec LAPI machine registration.
- VPS baseline is `os_prepare` + `os_wg` (see `specify-os-vps-role`, 2026-10-19).

## Alternatives And Risks

- Rebuild the `legacy` IPv4 forwarding in the role: needs a paid IPv4 per VPS
  and the exact rules of the current VPS (E-Q3); deferred.
- Static private key in the vault: simpler rebuilds with the same OPNsense
  peer, but a secret to manage; a host-generated key means a rebuilt VPS
  needs its new public key entered on OPNsense.
- CrowdSec as a host package: fewer moving parts on a tiny VPS, but splits
  from the repository's container model.
- Risk: an IPv6-only VPS is unreachable for IPv4-only clients; public entry
  needs the forwarding follow-up or a dual-stack front.
- Risk: firewall mistakes lock out SSH. Mitigation: non-empty allowlist
  enforced, SSH over the tunnel, `nft -c` check, timed rollback.

Approval status: skeleton and plan approved by the user on 2026-10-17
("start caddy/vps as podman"); IPv6-only scope set by the user on
2026-10-17. Task implementation needs a separate approval after the blockers
in `tasks.md` are resolved.

Change 2026-10-19 (owner): role renamed to `os_wg` (bare WireGuard plus an
optional edge part behind `os_wg_edge_enabled`); the nftables allowlist moves
to `os_prepare` as an optional part; CrowdSec is out of this change and
planned as a later container role (its requirement left the delta spec).
