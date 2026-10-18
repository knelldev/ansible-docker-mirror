# pve_ct_template Role

## Purpose

Build, test and replace Proxmox LXC templates through the Proxmox API.

## Local Contracts

- Variables prefixed `pve_ct_template_*`; secrets default to environment
  lookups, never literals.
- Multi-play role: no numbered task files; `playbooks/pve_ct_template.yml`
  calls phase files with `tasks_from`. `tasks/main.yml` stays the standard
  entry point.
- Every stop, convert or destroy of an existing guest goes through
  `tasks/destroy.yml` or uses a VMID this run created. Never touch guests
  without the name prefix or of type `qemu`.
- Clones and renames pass an explicit VMID (`api_nextid.yml`): old and new
  templates share a name.
- Phase blocks record failures in facts instead of failing, so the finish
  play always runs.

## Work Guidance

### Run

```bash
ansible-playbook playbooks/pve_ct_template.yml
```

Live runs need user approval per step (`openspec/changes/add-ct-template`).

## Verification

```bash
ansible-playbook --syntax-check playbooks/pve_ct_template.yml
ansible-lint playbooks/pve_ct_template.yml roles/pve_ct_template/
```

## Child DOX Index

None.
