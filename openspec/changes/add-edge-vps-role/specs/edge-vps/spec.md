## ADDED Requirements

### Requirement: Client addresses reach OPNsense

The entry VPS SHALL forward traffic for its public IPv4 through the WireGuard
tunnel without source NAT, except traffic the VPS answers itself.

#### Scenario: HTTPS request through the VPS

- **WHEN** a client connects to the VPS public IPv4 on port 443
- **THEN** OPNsense receives the connection with the client's address as
  source

### Requirement: SSH only from the allowlist

The VPS SHALL accept SSH only from `os_edge_ssh_allow`, and the role SHALL
refuse to apply firewall rules when that list is empty.

#### Scenario: Empty allowlist

- **WHEN** `os_edge_ssh_allow` is empty
- **THEN** the role fails before changing the firewall

### Requirement: CrowdSec reports to OPNsense

The VPS SHALL run a CrowdSec agent with the sshd collection that sends alerts
to the OPNsense LAPI over the tunnel.

#### Scenario: SSH brute force

- **WHEN** an address fails SSH logins repeatedly on the VPS
- **THEN** the alert appears on the OPNsense LAPI
