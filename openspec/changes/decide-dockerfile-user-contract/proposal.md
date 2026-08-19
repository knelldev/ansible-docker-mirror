## Why

The Dockerfile already creates UID 1000 user `ansible`, but the image contract
is not recorded as an accepted specification and mounted-file behavior is not
fully defined.

## Outcome

Document the image user, home and working paths, ownership, capabilities,
mounted inventory/secret expectations, and compatibility guarantees.

## Scope

- Define the non-root controller contract.
- Define build-time versus run-time files and permissions.
- Define compatibility checks for Docker and rootless execution.

## Exclusions

- No Dockerfile behavior change in this planning change.
- No rootful fallback or additional runtime service.

Approval status: planning only.
