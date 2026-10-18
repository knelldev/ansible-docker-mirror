## ADDED Requirements

### Requirement: Admin access

The baseline SHALL provide a local user `localadmin` with SSH key login, no usable
password and passwordless sudo, and SHALL leave the distribution's sshd and
firewall defaults unchanged.

#### Scenario: Login on a clone

- **WHEN** a clone of the template starts
- **THEN** `localadmin` can log in with its key and run sudo
- **AND** root cannot log in

### Requirement: Unique clone identity

Each clone SHALL get a new machine-id and new SSH host keys on its first boot,
before `sshd` starts, exactly once.

#### Scenario: Second boot

- **WHEN** a clone reboots
- **THEN** its machine-id and host keys stay the same as after first boot

### Requirement: Updates

The baseline SHALL apply security updates daily, and all package updates
weekly on Thursday from 04:00 with a reboot only when needed, followed by
Podman auto-update.

#### Scenario: Kernel-independent update

- **WHEN** the weekly update installs packages that need no restart
- **THEN** the guest does not reboot

### Requirement: Rootless-ready ID range

The baseline SHALL configure subordinate UID/GID allocation from 10000 to
65533, inside the container's 65536-ID map, for one app user per container,
and SHALL contain no application user.

#### Scenario: App role creates a user

- **WHEN** a `con_*` role creates its app user on a clone
- **THEN** the user gets a subuid/subgid range inside the map and rootless
  Podman runs

### Requirement: Reset before templating

The baseline SHALL remove the build key, SSH host keys, machine-id content,
NetworkManager connection files, hostname, logs, dnf cache, shell histories
and temporary files before the guest becomes a template.

#### Scenario: Template contents

- **WHEN** the build CT is converted to a template
- **THEN** none of these items remain and the build key cannot log in to a clone

### Requirement: Metrics

The baseline SHALL run node_exporter with the systemd collector, enabled at
boot.

#### Scenario: Clone started

- **WHEN** a clone has booted
- **THEN** node_exporter answers on port 9100 with systemd unit metrics
