# os_template_reset

Resets a guest right before it becomes a template: truncates
`/etc/machine-id`, removes SSH host keys, the first-boot marker, hostname,
NetworkManager connection files, logs, dnf cache, shell histories, `/tmp`,
`/var/tmp`, the local Ansible facts (`/etc/ansible/facts.d/*.fact`, run
records of the build) and as the last step root's `authorized_keys`. It
writes no run fact itself.

## Requirements

- Ansible core 2.17 or newer, no extra collections.
- EL 10 guest (paths are EL defaults). Do not run on a live host.

## Role variables

| Variable                                | Default                                                     | Meaning                                  |
| --------------------------------------- | ----------------------------------------------------------- | ---------------------------------------- |
| `os_template_reset_confirm`             | `false`                                                     | must be `true`, else the role fails      |
| `os_template_reset_remove_paths`        | hostname, first-boot marker, root history, `/root/.ansible` | removed completely                       |
| `os_template_reset_remove_patterns`     | `/etc/ssh/ssh_host_*`, `/home/**/.bash_history`             | files removed by pattern                 |
| `os_template_reset_empty_dirs`          | NM connections, `/var/cache/dnf`, `/tmp`, `/var/tmp`        | contents removed                         |
| `os_template_reset_clear_files_in`      | `/var/log`                                                  | files removed, directories kept          |
| `os_template_reset_truncate_machine_id` | `true`                                                      | empty `/etc/machine-id`                  |
| `os_template_reset_remove_root_keys`    | `true`                                                      | remove `/root/.ssh/authorized_keys` last |
| `os_template_reset_fact_enabled`        | `false`                                                     | no run fact after the reset              |

## Dependencies

None. Pairs with `os_prepare_firstboot_enabled`, which regenerates the
identity on the clone's first boot.

## Example playbook

```yaml
- hosts: build_guest
  roles:
    - role: os_template_reset
      vars:
        os_template_reset_confirm: true
```

## License

MIT. See the collection repository license.

## Author

knelldev
