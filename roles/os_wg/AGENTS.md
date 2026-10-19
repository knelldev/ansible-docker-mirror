# os_wg Role

## Purpose

Bare WireGuard: one interface with one peer (for an entry VPS: OPNsense
dials in over IPv6), plus an optional edge part (IPv4/IPv6 forwarding)
behind `os_wg_edge_enabled`. The VPS baseline is `os_prepare` + `os_wg`.

## Local Contracts

- Follows the `os_*` layout in [`roles/AGENTS.md`](../AGENTS.md); variables
  prefixed `os_wg_*`.
- DRAFT: only the variable contract exists; task files are TODOs. Plan and
  status live in `openspec/changes/add-edge-vps-role/`.
- Stores nothing under `app_path` (keys live in `/etc/wireguard`), so it has
  no `00-prepare.yml`.
- The host firewall is not part of this role: it is the optional nftables
  part of `os_prepare`. CrowdSec is planned as a separate container role.

## Work Guidance

Implement only after the plan's blockers are resolved and approved.

## Verification

```bash
ansible-playbook --syntax-check playbooks/os_wg.yml
ansible-lint roles/os_wg/ playbooks/os_wg.yml
```

## Child DOX Index

None.
