# os_edge Role

## Purpose

Entry VPS: WireGuard tunnel to OPNsense, forwarding of the whole public IPv4
into the tunnel without SNAT, nftables firewall, CrowdSec agent.

## Local Contracts

- Follows the `os_*` layout in [`roles/AGENTS.md`](../AGENTS.md); variables
  prefixed `os_edge_*`.
- DRAFT: only the variable contract exists; task files are TODOs. Plan and
  status live in `openspec/changes/add-edge-vps-role/`.
- Separate from `os_vps` (generic VPS tuning, `specify-os-vps-role`).
- Firewall changes must never lock out SSH: refuse an empty
  `os_edge_ssh_allow` and apply rules with a timed rollback.

## Work Guidance

Implement only after the plan's blockers are resolved and approved.

## Verification

```bash
ansible-playbook --syntax-check playbooks/os_edge.yml
ansible-lint roles/os_edge/ playbooks/os_edge.yml
```

## Child DOX Index

None.
