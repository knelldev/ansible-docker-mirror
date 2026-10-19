# os_template_reset Role

## Purpose

Reset a guest (CT now, VM template later) right before templating.

## Local Contracts

- Variables prefixed `os_template_reset_*`.
- Fails unless `os_template_reset_confirm` is true; never part of a role
  that runs on live hosts.
- Removing root's `authorized_keys` stays the last task.

## Work Guidance

Run only as the last step of a template build (`playbooks/pve_ct_template.yml`).

## Verification

```bash
ansible-lint roles/os_template_reset/
```

## Child DOX Index

None.
