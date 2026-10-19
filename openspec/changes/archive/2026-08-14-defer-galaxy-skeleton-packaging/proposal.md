## Why

The repository has a reusable non-Windows role pattern and a partially
configured Galaxy skeleton, but the skeleton currently assumes a Quadlet
application and the collection metadata is still templated. A generic starter
will make new OS, container, Kubernetes, and infrastructure roles consistent
without forcing every role into one runtime model.

## What Changes

- Package the repository as the `knelldev.rituals` collection.
- Replace the Quadlet-specific skeleton with a generic non-Windows role starter.
- Keep the repository role convention of `defaults/main/00-general.yml`,
  numbered static task files, `tasks/main.yml`, and `vars/main.yml`.
- Repair collection metadata, README, runtime requirements, and MIT legal text.
- Verify generated role output and collection build/lint behavior.

## Capabilities

### New Capabilities

- None; this is packaging and scaffolding behavior, not a deployed runtime feature.

### Modified Capabilities

- None.

## Impact

- `roles/.skeletons/role_skeleton/`, collection metadata, documentation, and
  generated packaging artifacts.
- No changes to existing role runtime behavior.
- Current role targets remain mixed by role; the generic skeleton targets
  non-Windows roles and documents EL 9/10 as its initial platform baseline.

## Alternatives And Risks

- Keeping the Quadlet example would make the starter unsuitable for generic OS,
  Kubernetes, and Proxmox roles.
- A generic skeleton intentionally contains less ready-made behavior; role
  authors add runtime-specific tasks and templates in the numbered slots.
- A collection name based on infrastructure would underspecify the broader
  automation scope, so the collection is named `knelldev.rituals`.
- Approval status: approved for implementation on 2026-08-14.
