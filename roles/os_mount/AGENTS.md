# os_mount Role

## Purpose

Configure NFS server and client on Linux hosts.

## Local Contracts

- Follows standard `os_*` role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `os_mount_*`
- Required before deploy: planned export paths, client access list, network connectivity between nodes

## Work Guidance

### Post-Run

1. `systemctl status nfs-server` — service running
2. Test export accessibility from clients
3. Verify client mount points persist across reboots

## Verification

```bash
ansible-lint roles/os_mount/
systemctl is-active nfs-server
showmount -e localhost
```

## Child DOX Index

None.
