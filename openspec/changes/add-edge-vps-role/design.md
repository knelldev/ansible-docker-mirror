## Context

- Migration repo: `edge-vps-geodns` (E-D1 to E-D3, E-Q3 open) and
  `inventory/opnsense.md` (VPS forwards its whole public IPv4 over `wg4`,
  OPNsense uses `reply-to wg4`, outbound NAT on wg4 to the VPS address).
- Repository contracts: `TECHSTACK.md`, `roles/AGENTS.md`; role generated from
  `roles/.skeletons/role_skeleton`.

## Decisions

### Host config vs container

WireGuard, sysctl and nftables are host configuration (templates + modules).
CrowdSec runs as a Podman Quadlet with a pinned image
(`crowdsecurity/crowdsec:v1.8.1`), reading sshd from the journal and talking
only to the OPNsense LAPI (local LAPI disabled).

### Forwarding without SNAT

Packets for the public IPv4 that the VPS does not answer itself go into the
tunnel unchanged (policy routing or DNAT to the same address on the peer, to
be confirmed against the current VPS). Replies come back through the tunnel
with the public IPv4 as source and leave via the public interface. WireGuard
uses `Table = off` so the VPS's own default route stays on the public side.

### Lockout safety

The role refuses an empty `os_edge_ssh_allow`, checks rules with `nft -c`,
and applies them with a timed revert unless confirmed.

## Open Questions

- E-Q3: what does the current VPS run (OS, WireGuard config, iptables or
  nftables rules)? The forwarding method copies what works there.
- Target OS for new VPS (Debian or EL)?
- CrowdSec as container or host package on a small VPS?
