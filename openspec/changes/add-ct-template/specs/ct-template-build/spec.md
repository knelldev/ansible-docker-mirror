## ADDED Requirements

### Requirement: Template build

The build SHALL produce LXC templates `ct-alma-10-dmz` (bridge `vmbr1`) and
`ct-alma-10-int` (full clone, bridge `vmbr0`) in pool `Templates` from the
newest stock `almalinux-10-default_*_amd64.tar.xz`, downloaded by the node to
storage `pve-z2`.

#### Scenario: Successful run

- **WHEN** the scheduled build runs and every step passes
- **THEN** both templates exist, are unprivileged, have only `nesting=1`,
  rootfs 15G and `mp0` 35G at `/data` on `pve-ssd`
- **AND** their notes state the Alma minor version, the git commit and the
  package diff against the previous template

#### Scenario: Node without vmbr1

- **WHEN** the configured node has no bridge `vmbr1`
- **THEN** the build fails before creating any guest

### Requirement: Tested replacement

The build SHALL replace the previous templates only after a clone of the new
template passes the test, and SHALL keep the previous templates on any
failure.

#### Scenario: Test fails

- **WHEN** any build or test step fails
- **THEN** the new templates, build CT and test clone are destroyed
- **AND** the previous templates are unchanged

#### Scenario: Clone running from the old template

- **WHEN** the test passes while a clone task from an old template is running
- **THEN** that old template is kept and removed by a later run

#### Scenario: Clone test checks

- **WHEN** the test clone starts
- **THEN** its SSH host keys and machine-id differ from the build CT
- **AND** network, DNS, `sshd`, rootless `podman run` as an unprivileged user
  and node_exporter work

### Requirement: Guest guard

The build SHALL stop, convert or destroy only LXC guests whose name starts
with `ct-` and whose VMID it created or recorded at the start of the run.

#### Scenario: VM template in the same pool

- **WHEN** pool `Templates` also holds VM templates
- **THEN** the build never changes them
