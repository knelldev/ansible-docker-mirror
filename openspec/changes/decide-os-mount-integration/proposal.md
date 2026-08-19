## Why

`roles/os_mount/` has a DOX contract but no implementation, defaults, tasks,
metadata, or playbook. The repository needs an explicit decision before NFS
behavior is added.

## Outcome

Define whether NFS server/client support belongs in this repository, which host
families and operating systems are supported, and how exports, mounts,
permissions, persistence, and verification are represented.

## Scope

- Decide server and client responsibilities.
- Define variable, inventory, and playbook boundaries.
- Define idempotence, mount persistence, firewall, and failure behavior.
- Define controlled verification requirements.

## Exclusions

- No role or playbook implementation in this planning change.
- No automatic storage provisioning or cloud filesystem integration.

## Risks and Alternatives

NFS behavior is OS- and network-sensitive. A host-managed role is simpler than
introducing a storage platform, but requires clear export and access controls.
The alternative is to keep NFS entirely outside this repository and document
only an integration contract.

Approval status: planning only. Implementation requires explicit approval after
the design and supported-platform decision are complete.
