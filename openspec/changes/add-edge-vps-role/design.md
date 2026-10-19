## Context

- Migration repo: `edge-vps-geodns` (E-D1 to E-D4, E-Q3) and
  `inventory/opnsense.md` (OPNsense uses `reply-to wg4` and outbound NAT on
  wg4 for the current VPS).
- User facts 2026-10-17: the current VPS (91.204.45.196) does not configure
  its public IPv4 on an interface; the provider routes it to the VPS, which
  forwards it into WireGuard. New VPSes are IPv6 only. OPNsense has a dynamic
  IPv6 prefix and reaches the internet over PPPoE.
- Repository contracts: `TECHSTACK.md`, `roles/AGENTS.md`; role generated from
  `roles/.skeletons/role_skeleton`.

## Decisions

### IPv6-only WireGuard endpoint (new)

The role builds a bare WireGuard server listening on the VPS's public IPv6.
OPNsense is the client: the VPS peer has no Endpoint, only PublicKey,
AllowedIPs (OPNsense tunnel address plus optional extras) and the tunnel
addresses; OPNsense sets PersistentKeepalive. `Table = off` keeps the VPS's
own routes untouched. MTU 1412 (PPPoE 1492 minus 80 bytes for WireGuard over
IPv6). No forwarding or DNAT of public traffic in this version.

### Keys stay on the host (new)

The VPS private key is generated on the host (`wg genkey`, mode 0600) and
loaded with `PostUp = wg set %i private-key …`, so it is neither in the
repository nor on the controller. The role prints the public key for
OPNsense; the OPNsense public key is a plain variable.

### Forwarding without SNAT: legacy only (closed)

The current VPS forwards its whole, provider-routed public IPv4 into the
tunnel without SNAT. This is mode `legacy`: documented here, no role path.
Exact rules stay unread (rest of E-Q3); they matter only if `legacy` is ever
rebuilt.

### Host config vs container

WireGuard and nftables are host configuration (templates + modules).
CrowdSec runs as a Podman Quadlet with a pinned image
(`crowdsecurity/crowdsec:v1.8.1`), reading sshd from the journal and talking
only to the OPNsense LAPI over the tunnel (E-D4; local LAPI disabled).

### Lockout safety

The role refuses an empty `os_prepare_firewall_ssh_allow`, also allows SSH over the
tunnel, checks rules with `nft -c`, and applies them with a timed revert
unless confirmed. ICMPv6 for neighbour discovery and packet-too-big stays
open, or IPv6 and PMTU break.

## Open Questions

- Target OS for new VPS (Debian or EL)?
- CrowdSec as container or host package on a small VPS?
- How do IPv4-only clients reach apps behind an IPv6-only VPS (forwarding
  follow-up, dual-stack front, keep `legacy`)?
- Tunnel addressing: IPv4 only inside the tunnel, or also a ULA IPv6?

## Decisions 2026-10-19 (owner)

- Role renamed `os_edge` → `os_wg`, variables `os_edge_*` → `os_wg_*`
  (`playbooks/os_wg.yml`). Scope: bare WireGuard (key, interface, peer, MTU)
  plus an optional edge part (IPv4/IPv6 forwarding etc.) behind
  `os_wg_edge_enabled`, default false.
- The nftables allowlist moves to `os_prepare` as an optional part
  (`os_prepare_firewall_enabled`, default false; variables and a TODO task
  file only). The lockout rules above apply there.
- CrowdSec leaves this role; it is planned as a later, separate container
  role (agent reporting to the OPNsense LAPI). The decision "Host config vs
  container" above therefore no longer applies to `os_wg`.
