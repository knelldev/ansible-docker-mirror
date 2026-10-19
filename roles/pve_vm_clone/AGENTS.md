# pve_vm_clone Role

## Purpose

Clone and configure Proxmox VM templates for downstream provisioning.

## Local Contracts

- Follows standard role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `pve_vm_clone_*`
- Required before run: Proxmox API access, source template availability, planned VM specs (CPU, memory, disk)

## Work Guidance

### Run

```bash
ansible-playbook playbooks/pve_vm_clone.yml -i <inventory>
```

### Post-Run

1. Verify VM cloned in Proxmox UI
2. Test VM boot and network connectivity
3. Validate template configuration

## Verification

```bash
ansible-playbook --syntax-check playbooks/pve_vm_clone.yml
ansible-lint roles/pve_vm_clone/
```

## Child DOX Index

None.
