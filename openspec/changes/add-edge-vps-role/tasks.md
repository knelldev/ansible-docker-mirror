## Status

- Approval: skeleton approved 2026-10-17; task implementation not approved.
- Plan state: skeleton done, implementation blocked.
- Blocker: E-Q3 (inventory of the current VPS) in the migration repo; target
  OS; CrowdSec container vs package.

## 1. Skeleton

- [x] 1.1 Generate `roles/os_edge/` from the role skeleton; write the
      variable contract, README, AGENTS and TODO task files.
- [x] 1.2 Add `playbooks/os_edge.yml`.

## 2. Implementation (after approval)

- [ ] 2.1 Install wireguard-tools and nftables; WireGuard interface.
- [ ] 2.2 Forwarding (sysctl, routing, nftables) copied from the current VPS.
- [ ] 2.3 Firewall with SSH allowlist guard and timed rollback.
- [ ] 2.4 CrowdSec Quadlet registered on the OPNsense LAPI; optional bouncer.

## 3. Verification

- [x] 3.1 `ansible-lint`, `yamllint`, syntax check for the skeleton.
- [ ] 3.2 Fresh test VPS: forwarding works and client IPs arrive at OPNsense.
      Rollback: DNS back to the old VPS.

## Verification Evidence

- 2026-10-17: skeleton passes `ansible-lint` (production), `yamllint` and the
  syntax check.

## Next Action

- Inventory the current VPS (E-Q3, read-only) and decide the forwarding
  method.
