## ADDED Requirements

### Requirement: WireGuard endpoint on IPv6

The entry VPS SHALL run a WireGuard server on its public IPv6 with exactly one
peer (OPNsense) that has no Endpoint, and SHALL NOT forward public traffic
into the tunnel.

#### Scenario: OPNsense dials in

- **WHEN** OPNsense connects to the VPS public IPv6 and listen port with the
  configured keys
- **THEN** the tunnel comes up and both tunnel addresses answer pings

#### Scenario: Large packets over PPPoE

- **WHEN** a full-size packet crosses the tunnel
- **THEN** it passes with the tunnel MTU 1412 without fragmentation errors

### Requirement: VPS private key stays on the host

The role SHALL generate the VPS private key on the host when missing, SHALL
NOT store it in the repository or on the controller, and SHALL print the VPS
public key.

#### Scenario: First run

- **WHEN** the role runs on a fresh VPS
- **THEN** a key file with mode 0600 exists on the host and the run output
  shows the public key, public IPv6, listen port and tunnel addresses

#### Scenario: Rerun

- **WHEN** the role runs again
- **THEN** the existing key is kept

### Requirement: SSH only from the allowlist

The VPS SHALL accept SSH only from `os_edge_ssh_allow` and over the tunnel,
and the role SHALL refuse to apply firewall rules when that list is empty.

#### Scenario: Empty allowlist

- **WHEN** `os_edge_ssh_allow` is empty
- **THEN** the role fails before changing the firewall

### Requirement: CrowdSec reports to OPNsense

The VPS SHALL run a CrowdSec agent with the sshd collection that sends alerts
to the OPNsense LAPI over the tunnel.

#### Scenario: SSH brute force

- **WHEN** an address fails SSH logins repeatedly on the VPS
- **THEN** the alert appears on the OPNsense LAPI
