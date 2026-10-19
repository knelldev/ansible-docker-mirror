## Context

The repository targets Linux hosts and rootless container workloads. Any mount
role must align with `TECHSTACK.md`, the role skeleton in `roles/AGENTS.md`, and
the external inventory model in `docs/execution.md`.

## Decisions Required

1. Support NFS server, client, or both.
2. Select supported Linux families and package/service names.
3. Define export records, client access, mount options, ownership, and mode.
4. Decide whether firewall rules are owned by this role or a preparation role.
5. Decide whether mounts use `/etc/fstab`, systemd mount units, or both.
6. Define safe behavior when a server is unavailable during a client run.

## Verification Shape

The future implementation must prove idempotent exports and mounts, persistent
mount behavior, restricted client access, service health, and clear failure
output without requiring a live storage provider during static checks.
