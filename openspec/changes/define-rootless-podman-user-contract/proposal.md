## Why

The repository uses rootless Podman and systemd user services, but the reusable
contract for preparing their service user is not recorded. A small base
contract will let future container roles reuse the same identity, ownership,
linger, and network assumptions without inventing role-specific variations.

## What Changes

- Define a reusable non-root Podman preparation contract for Linux container roles.
- Define the coupled service user and group relationship.
- Define stable UID/GID and filesystem ownership requirements where needed.
- Define optional systemd linger for rootless user services.
- Define the minimum container identity and network settings that a future role
  may reuse.
- Keep ordinary defaults lean and keep role-specific container settings in the
  consuming role.

## Exclusions

- No implementation in the role skeleton or existing roles.
- No Kubernetes, Proxmox, Windows, Docker, or generic host-user framework.
- No new collection, dependency, external service, or container deployment.
- No decision to make every role rootless or to migrate existing roles.

## Risks And Alternatives

- Stable IDs and linger can affect host account state and must remain opt-in.
- A shared contract could be too broad if it includes container-specific
  settings; keep only settings common to rootless Podman roles.
- The simpler alternative is to document each container role independently, but
  that would duplicate identity and ownership rules.

## Approval Status

- Plan created only; inactive and not approved for implementation.
