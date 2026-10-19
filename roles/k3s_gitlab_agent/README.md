# K3s GitLab Agent

Registers GitLab agents for Kubernetes (agentk) in their config projects and
deploys each one on K3s with the `gitlab/gitlab-agent` Helm chart. The agent
token lives only in a Kubernetes Secret, and the agent's rights are namespaced
Roles per listed target namespace. Nothing cluster-wide is granted.

## Requirements

- Ansible core 2.17 or newer, the `kubernetes.core` collection
  (`collections/requirements.yml`), Helm on the K3s host.
- K3s with a kubeconfig on the target (default `/etc/rancher/k3s/k3s.yaml`).
- A GitLab API token (vault) with `api` scope and the Maintainer role on every
  config project.
- KAS enabled on GitLab and reachable from the cluster pods.
- The agent's own `.gitlab/agents/<name>/config.yaml` in the config project.
  The role does not write it. Without `ci_access` there, no CI job can use the
  agent:

  ```yaml
  # .gitlab/agents/k3s-lab/config.yaml
  ci_access:
    projects:
      - id: my-group/my-app
  ```

## Role Variables

Settings (`defaults/main/10-k3s-gitlab-agent.yml`). Only the API token has no
working default.

| Variable                                | Default                                               | Purpose                                                  |
| --------------------------------------- | ----------------------------------------------------- | -------------------------------------------------------- |
| `con_gitlab_external_url`               | `http://example.com/`                                 | Shared GitLab URL (from the `con_gitlab` settings)       |
| `k3s_gitlab_agent_gitlab_external_url`  | `con_gitlab_external_url`                             | GitLab URL for the API and the KAS defaults              |
| `k3s_gitlab_agent_api_token`            | `__REQUIRED__`                                        | GitLab API token (vault)                                 |
| `k3s_gitlab_agent_kas_scheme`           | `wss` for an `https` URL, else `ws`                   | KAS scheme: `grpc`, `grpcs`, `ws` or `wss`               |
| `k3s_gitlab_agent_kas_host`             | host of the GitLab URL                                | KAS host                                                 |
| `k3s_gitlab_agent_kas_port`             | port of the GitLab URL, usually `""`                  | KAS port; empty leaves it out                            |
| `k3s_gitlab_agent_kas_path`             | `/-/kubernetes-agent/`                                | KAS path; `""` for a KAS on its own port                 |
| `k3s_gitlab_agent_kas_address`          | built from the four parts                             | Whole KAS address agentk dials; overrides the parts      |
| `k3s_gitlab_agent_kas_ca_cert`          | `""`                                                  | PEM of a private CA for KAS                              |
| `k3s_gitlab_agent_kubeconfig_path`      | `/etc/rancher/k3s/k3s.yaml`                           | Kubeconfig on the K3s host                               |
| `k3s_gitlab_agent_helm_binary_path`     | `/usr/local/bin/helm`                                 | Helm on the K3s host                                     |
| `k3s_gitlab_agent_chart_version`        | `""` (latest)                                         | Chart version; set to pin                                |
| `k3s_gitlab_agent_image_tag`            | `""` (GitLab server version, `19.5.0-ee` → `v19.5.0`) | agentk image tag; set to pin                             |
| `k3s_gitlab_agent_resources`            | `{}` (chart default: none)                            | agentk container resources                               |
| `k3s_gitlab_agent_monitoring`           | `true`                                                | Metrics Service and `prometheus.io/*` scrape annotations |
| `k3s_gitlab_agent_replicas_auto`        | `true`                                                | 1 replica on one node, 2 from two nodes on               |
| `k3s_gitlab_agent_replicas`             | `null`                                                | Explicit replica count, overrides auto                   |
| `k3s_gitlab_agent_replicas_max`         | `2`                                                   | Upper bound for auto                                     |
| `k3s_gitlab_agent_rotate_token`         | `false`                                               | One-shot token rotation for all listed agents            |
| `k3s_gitlab_agent_helm_wait`            | `true`                                                | Helm waits for the release                               |
| `k3s_gitlab_agent_helm_timeout`         | `5m`                                                  | Helm timeout                                             |
| `k3s_gitlab_agent_health_check_retries` | `18`                                                  | Rollout checks before the run fails                      |
| `k3s_gitlab_agent_health_check_delay`   | `10`                                                  | Seconds between rollout checks                           |
| `k3s_gitlab_agent_failure_log_lines`    | `100`                                                 | agentk log lines shown on failure                        |
| `k3s_gitlab_agent_config_list`          | `[]`                                                  | Agents, see below                                        |

GitLab API and Kubernetes calls verify certificates per the shared
`http.ssl_verify` (default `false`), like the other roles.

`vars/main.yml` holds what is not a setting: `app_path`, the API URL, the
allowed KAS schemes, name rules, annotation keys, and lazy expressions for
derived values (replica count, image tag, per-agent names, URLs and token ids).

### KAS address

The default is the main-domain form derived from the GitLab URL
(`wss://<host>/-/kubernetes-agent/`). Override single parts, or the whole
address, in the inventory. A KAS on its own port without TLS, as in the lab:

```yaml
k3s_gitlab_agent_kas_scheme: ws
k3s_gitlab_agent_kas_host: 10.0.10.25
k3s_gitlab_agent_kas_port: 8150
k3s_gitlab_agent_kas_path: ""
# -> ws://10.0.10.25:8150
```

Set `k3s_gitlab_agent_kas_ca_cert` only for a private CA; a public certificate
(for example Let's Encrypt) needs none.

### Versions

Nothing is pinned by default: Helm installs the latest chart, and the agentk
image tag follows the GitLab server version (`GET /api/v4/version`), so agentk
moves with GitLab upgrades. Set `k3s_gitlab_agent_chart_version` or
`k3s_gitlab_agent_image_tag` to pin either one.

### Agents

```yaml
k3s_gitlab_agent_config_list:
  - name: k3s-lab # agent name in GitLab and Helm release name
    project: my-group/my-app # config project: path or numeric id
    # namespace: gitlab-agent-my-app   # where agentk runs (this is the default)
    targets:
      - namespace: my-app
        rules: # a Role with these rules, or ...
          - apiGroups: [""]
            resources: [configmaps]
            verbs: [get, list]
      - namespace: my-app-review
        cluster_role: edit # ... a RoleBinding to an existing ClusterRole
```

Each target needs exactly one of `rules` or `cluster_role`; the run fails
before any change otherwise. Target namespaces are created when missing.

**One agent per project.** On GitLab Free there is no `access_as`
impersonation: every project that the agent's `ci_access` authorizes gets all
of the agent's rights in all of its target namespaces. Give each project (each
trust boundary) its own agent and list only its namespaces.

There are no namespace wildcards (RBAC has none). Wildcards belong in
`ci_access.environments` in the config project.

Example for kube-01-cv, with the rules its CI deploy needs today (from
`kube_01_cv/deploy/ci-deployer.yaml`). Not a default; copy into the inventory
and set the real project path:

```yaml
# k3s_gitlab_agent_config_list:
#   - name: kube-01-cv
#     project: <group>/kube_01_cv
#     targets:
#       - namespace: kube-01-cv
#         rules:
#           # What the chart renders; Secrets also hold Helm's release records.
#           - apiGroups: [""]
#             resources: [configmaps, secrets, services, persistentvolumeclaims]
#             verbs: [get, list, watch, create, update, patch, delete]
#           - apiGroups: [apps]
#             resources: [deployments, statefulsets]
#             verbs: [get, list, watch, create, update, patch, delete]
#           # The migration Job is a Helm hook.
#           - apiGroups: [batch]
#             resources: [jobs, cronjobs]
#             verbs: [get, list, watch, create, update, patch, delete]
#           - apiGroups: [networking.k8s.io]
#             resources: [ingresses, networkpolicies]
#             verbs: [get, list, watch, create, update, patch, delete]
#           # Read-only: rollout status and failure diagnostics.
#           - apiGroups: [apps]
#             resources: [replicasets]
#             verbs: [get, list, watch]
#           - apiGroups: [""]
#             resources: [pods, pods/log, events]
#             verbs: [get, list, watch]
```

## What the role does per agent

1. Finds the agent by name in the config project, registers it when missing.
2. Creates the agent namespace. Reuses Secret `<name>-token` (key `token`)
   when present; otherwise creates one agent token and writes it there. The
   Secret carries the token id as annotation `gitlab.com/agent-token-id`.
3. Creates a Role and RoleBinding (or a RoleBinding to `cluster_role`) per
   target for the ServiceAccount `<name>-agentk` in the agent namespace.
4. Writes the chart values to `/data/gitlab_agent/<name>/values.yaml` on the
   host that runs Helm (`app_path`, mode 0600, no token) and installs the chart with them:
   `rbac.create: false` and `config.operational_container_scanning.enabled:
false` (both would add cluster-wide RBAC), `config.secretName`, and the
   Secret's token id in `podAnnotations`. For a manual change on the host:
   `helm upgrade <name> gitlab/gitlab-agent -n gitlab-agent-<name> -f <file>`.
5. Waits for all agentk replicas to be ready; on failure prints pod state,
   events and log lines, then fails.
6. Prints a summary per agent: id, created or reused, token
   created/reused/rotated, token id, revoked token ids, targets.

A rerun with an unchanged inventory creates nothing in GitLab: the agent, the
Secret and its token are reused. Check mode (`--check`) is not supported.

## Token rotation

Run once with `k3s_gitlab_agent_rotate_token: true`, then set it back. For
every listed agent the role creates a new token and writes it to the Secret.
The new token id in `podAnnotations` changes the pod template, so Helm rolls
the pods. After the rollout is healthy the role revokes every other token of
the agent. GitLab allows two active tokens per agent; at the limit the role
first revokes the tokens that the Secret does not hold.

A run that fails between creating a token and writing the Secret leaves an
unused token in GitLab. The next rotation revokes it.

## Limits

- Agents, Roles and namespaces removed from the list are not cleaned up.
  Switching a target between `rules` and `cluster_role` leaves the old
  binding in place; delete it by hand.
- At most 100 agents per project and 100 tokens per agent are read (one API
  page).
- agentk's own namespace gets no Role. If agentk needs rights there, add the
  agent namespace as a target.

## Dependencies

None (`meta/main.yml`).

## Example Playbook

```yaml
- name: "Playbook: k3s_gitlab_agent"
  hosts: all
  roles:
    - k3s_gitlab_agent
```

The inventory lives in its own repo; set the variables on the cluster group
and limit the run to its K3s servers (controllers). The role is cluster-only:
the tasks run once, on the first host of the play, and fail early when that
host has no kubeconfig.
Dev (lab) and prod differ only in their group vars:

```yaml
# group_vars/k3s_lab.yml (dev)
k3s_gitlab_agent_api_token: "{{ vault_k3s_gitlab_agent_api_token }}"
k3s_gitlab_agent_kas_scheme: ws
k3s_gitlab_agent_kas_host: 10.0.10.25
k3s_gitlab_agent_kas_port: 8150
k3s_gitlab_agent_kas_path: ""
k3s_gitlab_agent_config_list:
  - name: k3s-lab
    project: my-group/my-app
    targets:
      - namespace: my-app
        cluster_role: edit
```

```yaml
# group_vars/k3s_prod.yml (prod): KAS on the GitLab domain, versions pinned
k3s_gitlab_agent_api_token: "{{ vault_k3s_gitlab_agent_api_token }}"
k3s_gitlab_agent_chart_version: "2.33.0"
k3s_gitlab_agent_image_tag: "v19.5.0"
k3s_gitlab_agent_config_list:
  - name: k3s-prod
    project: my-group/my-app
    targets:
      - namespace: my-app
        cluster_role: edit
```

```bash
ansible-playbook playbooks/k3s_gitlab_agent.yml --limit <controller group>
```

## Verification

```bash
ansible-playbook --syntax-check playbooks/k3s_gitlab_agent.yml
ansible-lint roles/k3s_gitlab_agent playbooks/k3s_gitlab_agent.yml
yamllint roles/k3s_gitlab_agent playbooks/k3s_gitlab_agent.yml
```

After a run: the agent shows as connected in GitLab (Operate > Kubernetes
clusters); `kubectl get clusterrolebindings -o wide | grep <name>-agentk`
returns nothing.

## License

MIT. See the collection repository license.

## Author

knelldev
