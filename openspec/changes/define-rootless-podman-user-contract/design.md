## Context

Future Podman roles may run containers as a non-root user through systemd user
services. The service account, group ownership, UID/GID stability, linger, and
network behavior must be consistent before roles can safely share a base
pattern.

## Proposed Contract

1. Create the service user and matching primary group together or create
   neither. Do not expose independent create-user and create-group switches.
2. Use role-derived user and group names by default. Permit explicit names and
   numeric UID/GID overrides only when a consuming role has a concrete need.
3. Make filesystem ownership follow the prepared service identity for managed
   application storage; retain explicit ownership overrides for container
   subdirectories that require root or a container-specific numeric ID.
4. Make systemd linger opt-in and apply it only when rootless user services
   must run without an interactive login.
5. Keep container identity settings separate from host account creation. A
   future role may configure container `user`, `group`, or numeric IDs without
   changing the host service account contract.
6. Keep network configuration role-specific except for reusable rootless
   Podman prerequisites and documented naming/ownership expectations.

## Boundaries

- Preparation owns the host user, group, storage ownership, and optional linger.
- The consuming container role owns image, container user/group, volumes,
  networks, ports, and service-specific environment.
- Shared defaults expose only behavior that is common and commonly changed.

## Decisions Needed Before Activation

- Exact variable names for the service account, UID/GID, linger, and container
  identity settings.
- Whether the base is implemented as a role dependency, an included task file,
  or a skeleton convention.
- Which rootless network prerequisites are common enough to standardize.

## Verification Approach

- Validate the resulting role/task structure with Ansible syntax checks.
- Verify idempotent user, group, ownership, and linger behavior with a suitable
  Linux test target.
- Verify rootless Podman user-service execution and network connectivity.
- Run configured `ansible-lint`, `yamllint`, and repository quality checks.
