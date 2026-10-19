# os_container

Installs Podman on EL hosts, moves rootful storage to
`os_container_data_root`, configures the Podman auto-update timer, and sets
optional rootless defaults.

## Requirements

- Ansible core 2.17 or newer, no extra collections.
- EL 9 or EL 10 with EPEL reachable. SELinux tasks run only where SELinux
  is enabled.

## Role variables

| Variable                               | Default                                      | Meaning                                                                                                                             |
| -------------------------------------- | -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `os_container_data_root`               | `{{ storage_base_path }}/containers/storage` | rootful graphroot                                                                                                                   |
| `os_container_auto_update`             | `true`                                       | configure `podman-auto-update.timer`                                                                                                |
| `os_container_auto_update_schedule`    | `Wed *-*-* 02:00:00`                         | timer `OnCalendar`                                                                                                                  |
| `os_container_subid_min` / `_max`      | unset                                        | subordinate ID range for new users in `/etc/login.defs` (`COUNT` = max - min + 1)                                                   |
| `os_container_default_netns`           | unset                                        | default network for all Podman users, drop-in in `/etc/containers/containers.conf.d/` (e.g. `host` where `/dev/net/tun` is missing) |
| `os_container_unprivileged_port_start` | unset                                        | `net.ipv4.ip_unprivileged_port_start`, set at boot by a oneshot unit                                                                |

## Dependencies

None.

## Example playbook

```yaml
- hosts: containers
  roles:
    - role: os_container
      vars:
        os_container_subid_min: 10000
        os_container_subid_max: 65533
        os_container_default_netns: host
```

## License

MIT. See the collection repository license.

## Author

knelldev
