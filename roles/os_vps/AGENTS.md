# os_vps Role

## Purpose

Optimize Linux hosts for VPS deployment (system tuning, monitoring, security hardening).

## Local Contracts

- Follows standard `os_*` role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `os_vps_*`

## Work Guidance

Add this role to an appropriate playbook with external inventory.

### Post-Run

1. `sysctl -a | grep tuned` — system tuning applied
2. Verify monitoring services running
3. Test security configurations

## Verification

```bash
ansible-playbook --syntax-check playbooks/os_vps.yml
ansible-lint roles/os_vps/
sysctl -a | grep tuned
```

The role is not currently implemented and `playbooks/os_vps.yml` does not yet
exist. These commands are a target verification contract for a future approved
implementation, not runnable checks today.

## Child DOX Index

None.
