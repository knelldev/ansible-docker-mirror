# K3s

Installs K3s servers and agents with the upstream install script, plus Helm.

## Requirements

- Ansible core 2.17 or newer, the `kubernetes.core` collection for the
  optional namespace setup.
- Linux hosts with the ports from the
  [K3s networking requirements](https://docs.k3s.io/installation/requirements#networking)
  open between them (6443 to the servers; 2379-2380 between servers with
  embedded etcd).

## Topology

`os_k3s_server: true` (host or group var) marks a server; every other host in
the play becomes an agent. Supported: one server, or an odd number of servers
(3, 5, 7) with embedded etcd, each plus any number of agents.

- The first server of the play (inventory order) installs first. With more
  than one server it gets `--cluster-init` (embedded etcd); a single server
  installs as before.
- The other servers and all agents join it with its URL
  (`https://<fqdn>:6443`) and node token, read once from the first server.
- An even server count only warns: two servers keep no etcd quorum when one
  fails.
- Servers and agents must be in the same run, so the joiners get the first
  server's URL and token.

## Role Variables

| Variable                              | Default  | Purpose                                      |
| ------------------------------------- | -------- | -------------------------------------------- |
| `os_k3s_server`                       | `false`  | This host is a K3s server (controller)       |
| `os_k3s_channel`                      | `stable` | K3s channel or version                       |
| `os_k3s_server_allow_schedule`        | `true`   | Allow workload pods on servers               |
| `os_k3s_server_additional_parameters` | `""`     | Extra install arguments (servers and agents) |
| `os_k3s_node_external_ip_override`    | `false`  | Pass `os_k3s_node_external_ip`               |
| `os_k3s_helm_install`                 | `true`   | Install Helm                                 |

## Example Playbook

```yaml
- hosts: all
  roles:
    - os_k3s
```

```bash
ansible-playbook playbooks/os_k3s.yml -i <inventory> --limit <k3s cluster group>
```

## License

MIT

## Author Information

Maintained by the repository contributors.
