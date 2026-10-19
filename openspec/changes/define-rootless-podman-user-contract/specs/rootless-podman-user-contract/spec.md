## Requirements

### Requirement: Coupled service account preparation

The base contract MUST create a service user and its matching primary group as
one operation, or create neither.

#### Scenario: Account creation is disabled

- **WHEN** a consuming role does not opt into service-account creation
- **THEN** no service user or group is created
- **AND** managed storage uses its documented fallback ownership

#### Scenario: Account creation is enabled

- **WHEN** a consuming role opts into service-account creation
- **THEN** the service user and matching primary group are both present
- **AND** managed storage can be owned by that identity

### Requirement: Stable identity overrides

The base contract MUST allow a consuming role to provide explicit user/group
names and stable numeric UID/GID values when required by a container image or
shared storage contract.

#### Scenario: Image requires stable IDs

- **WHEN** a consuming role supplies UID/GID overrides
- **THEN** account creation and managed ownership use those requested IDs
- **AND** the defaults remain unchanged for roles without that requirement

### Requirement: Optional systemd linger

The base contract MUST make linger opt-in.

#### Scenario: Rootless service needs boot-time availability

- **WHEN** a consuming role enables linger
- **THEN** the service user is permitted to run its systemd user services without
  an interactive login

#### Scenario: Linger is not needed

- **WHEN** linger is not enabled
- **THEN** the base preparation does not change linger state

### Requirement: Container and network boundaries

The base contract MUST distinguish host account preparation from
container-specific identity and network configuration.

#### Scenario: Container role supplies runtime settings

- **WHEN** a consuming role defines container user/group, IDs, volumes, or
  networks
- **THEN** those settings remain owned by the consuming role
- **AND** they do not silently alter unrelated host account defaults
