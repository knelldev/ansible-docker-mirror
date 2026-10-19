# os_container

Installs Podman on EL hosts, moves rootful storage to
`os_container_data_root`, configures the Podman auto-update timer, and sets
optional rootless defaults.

## Requirements

- Ansible core 2.17 or newer, no extra collections.
- EL 9 or EL 10 with EPEL reachable. SELinux tasks run only where SELinux
  is enabled.

## Role variables

| Variable                               | Default                                      | Meaning                                                                                                                       |
| -------------------------------------- | -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `os_container_data_root`               | `{{ storage_base_path }}/containers/storage` | rootful graphroot                                                                                                             |
| `os_container_auto_update`             | `true`                                       | configure `podman-auto-update.timer`                                                                                          |
| `os_container_auto_update_schedule`    | `Wed *-*-* 02:00:00`                         | timer `OnCalendar`                                                                                                            |
| `os_container_rootless`                | `false`                                      | `true`: subordinate ID range for new users in `/etc/login.defs`; `false` removes these lines (OS defaults)                    |
| `os_container_subid_min` / `_max`      | `100000` / `600100000`                       | that range                                                                                                                    |
| `os_container_subid_count`             | min(65536, max - min + 1)                    | IDs per new user                                                                                                              |
| `os_container_netns_host`              | `false`                                      | `true`: network namespace `host` for all Podman users (e.g. where `/dev/net/tun` is missing)                                  |
| `os_container_unprivileged_port_start` | `null` (off)                                 | `net.ipv4.ip_unprivileged_port_start`, set at boot by a oneshot unit (VM and LXC); unset removes the unit and sets 1024 again |

Each switch also reverts its setting when turned off. All Podman settings of
the role go into one drop-in, `/etc/containers/containers.conf.d/50-os-container.conf`,
which is absent when it would be empty.

## Dependencies

None.

## Example playbook

```yaml
- hosts: containers
  roles:
    - role: os_container
      vars:
        os_container_rootless: true
        os_container_subid_min: 10000
        os_container_subid_max: 65533
        os_container_netns_host: true
```

## License

MIT. See the collection repository license.

## Author

knelldev
