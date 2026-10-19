## Status

- Approval: skeleton approved 2026-10-17; IPv6-only scope set 2026-10-17;
  task implementation not approved.
- Plan state: skeleton done, implementation blocked.
- Blocker: target OS.
- 2026-10-19: renamed to `os_wg` and narrowed (see design.md, Decisions
  2026-10-19).

## 1. Skeleton

- [x] 1.1 Generate `roles/os_wg/` from the role skeleton; write the
      variable contract, README, AGENTS and TODO task files.
- [x] 1.2 Add `playbooks/os_wg.yml`.
- [x] 1.3 Narrow to an IPv6-only WireGuard endpoint; `legacy` IPv4
      forwarding documented only.

## 2. Implementation (after approval)

- [ ] 2.1 Install wireguard-tools and nftables.
- [ ] 2.2 Host-generated key, WireGuard interface (no peer Endpoint, MTU
      1412), print the OPNsense peer data.
- [ ] 2.3 Firewall (now the optional nftables part of `os_prepare`,
      2026-10-19): SSH allowlist guard, WireGuard port, ICMPv6, timed
      rollback.
- [ ] 2.4 Edge part behind `os_wg_edge_enabled`: IPv4/IPv6 forwarding.

## 3. Verification

- [x] 3.1 `ansible-lint`, `yamllint`, syntax check for the skeleton.
- [ ] 3.2 Fresh test VPS: OPNsense dials in, tunnel pings both ways, SSH
      only from the allowlist. Rollback: destroy the test VPS.

## Follow-ups

- CrowdSec agent as a separate container role, reporting to the OPNsense
  LAPI over the tunnel (moved out of this change on 2026-10-19).
- `os_wg_edge (forwarding rules)`: forward or DNAT public IPv6 traffic into the tunnel
  (disabled by default).
- IPv4 reachability for IPv4-only clients.

## Verification Evidence

- 2026-10-17: skeleton passes `ansible-lint` (production), `yamllint` and the
  syntax check.
- 2026-10-17: IPv6-only rework passes the same checks and
  `openspec validate --strict`.

## Next Action

- Decide target OS and CrowdSec packaging, then approve implementation.
