# os_prepare

Base preparation for EL hosts: packages, `/data` with group `data`,
dnf-automatic, journald and logrotate settings, a custom script, and
switchable parts for local admin access, first-boot identity, node_exporter
and a weekly update window.

## Requirements

- Ansible core 2.17 or newer, no extra collections.
- EL 9 or EL 10 with EPEL reachable.

## Role variables

`defaults/main/10-os.yml`: `os_prepare_packages`,
`os_prepare_dnf_automatic_enabled`, logrotate and journald settings.
`defaults/main/30-customize.yml`: `os_prepare_custom_script`.

Switchable parts (`defaults/main/20-parts.yml`). Defaults for existing
hosts (user, 2026-10-18): the daily dnf-automatic run only checks and
reports in the motd (the old config put its settings in sections dnf 4
ignores, so this keeps today's behavior), and a
weekly full update runs Thu 04:00, after the Thu 02:00 PBS backup, without
reboot. Hosts outside the backed-up PBS pools (DMZ, CORE, INT) get the
weekly update without a fresh backup. The other parts are off by default.
`playbooks/pve_ct_template.yml` sets its own values: daily security updates
applied, weekly reboot `when-needed`.

| Variable                                 | Default                  | Meaning                                                                                    |
| ---------------------------------------- | ------------------------ | ------------------------------------------------------------------------------------------ |
| `os_prepare_dnf_automatic_upgrade_type`  | `default`                | daily dnf-automatic: `default` (all) or `security`                                         |
| `os_prepare_dnf_automatic_apply_updates` | `false`                  | daily: `false` checks and reports only, `true` installs                                    |
| `os_prepare_dnf_automatic_reboot`        | `never`                  | daily (dnf 4): `never`, `when-changed`, `when-needed`                                      |
| `os_prepare_data_group`                  | `storage_group` (`data`) | group of `storage_base_path`                                                               |
| `os_prepare_admin_enabled`               | `false`                  | create the admin user                                                                      |
| `os_prepare_admin_user`                  | `localadmin`             | key-only login, locked password, sudo `NOPASSWD`                                           |
| `os_prepare_admin_pubkeys`               | `[]`                     | required when enabled                                                                      |
| `os_prepare_firstboot_enabled`           | `false`                  | `firstboot-identity.service`: new machine-id and SSH host keys once per clone, before sshd |
| `os_prepare_node_exporter_enabled`       | `false`                  | EPEL `node-exporter`, unit `node_exporter`, args `--collector.systemd`                     |
| `os_prepare_weekly_update_enabled`       | `true`                   | second dnf-automatic unit with its own config, always installs                             |
| `os_prepare_weekly_update_oncalendar`    | `Thu *-*-* 04:00:00`     | weekly timer                                                                               |
| `os_prepare_weekly_update_upgrade_type`  | `default`                | weekly: all updates                                                                        |
| `os_prepare_weekly_update_reboot`        | `never`                  | weekly reboot policy; the template playbook sets `when-needed`                             |
| `os_prepare_firewall_enabled`            | `false`                  | nftables allowlist; draft, `tasks/80-firewall.yml` is a TODO                               |
| `os_prepare_firewall_ssh_port`           | `22`                     | SSH port of the allowlist                                                                  |
| `os_prepare_firewall_ssh_allow`          | `[]`                     | source CIDRs allowed to SSH; must not be empty when enabled                                |

Systemd units of the optional parts render from `templates/systemd-unit.j2`
through the map `os_prepare_systemd_units` in `vars/main.yml`.

## Dependencies

None.

## Example playbook

```yaml
- hosts: servers
  roles:
    - role: os_prepare
      vars:
        os_prepare_admin_enabled: true
        os_prepare_admin_pubkeys:
          - ssh-ed25519 AAAA... localadmin
```

## License

MIT. See the collection repository license.

## Author

knelldev
