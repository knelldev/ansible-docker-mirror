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
- The agent's own `.gitlab/agents/<name>/config.yaml` (with `ci_access`) in
  the config project. The role does not write it.

## Role Variables

Defaults (`defaults/main/10-k3s-gitlab-agent.yml`):

| Variable                               | Default                                   | Purpose                                       |
| -------------------------------------- | ----------------------------------------- | --------------------------------------------- |
| `k3s_gitlab_agent_gitlab_external_url` | `con_gitlab_external_url`                 | GitLab URL for the API and the KAS default    |
| `k3s_gitlab_agent_api_token`           | `__REQUIRED__`                            | GitLab API token (vault)                      |
| `k3s_gitlab_agent_api_validate_certs`  | `true`                                    | Verify the GitLab API certificate             |
| `k3s_gitlab_agent_kas_address`         | `wss://<gitlab host>/-/kubernetes-agent/` | KAS address agentk dials                      |
| `k3s_gitlab_agent_kas_ca_cert`         | `""`                                      | PEM of a private CA for KAS                   |
| `k3s_gitlab_agent_chart_version`       | `2.33.0`                                  | Pinned chart version                          |
| `k3s_gitlab_agent_image_tag`           | `v19.5.0`                                 | Pinned agentk image; match GitLab major.minor |
| `k3s_gitlab_agent_resources`           | requests 50m CPU, 128Mi memory            | agentk container resources                    |
| `k3s_gitlab_agent_replicas_auto`       | `true`                                    | 1 replica on one node, 2 from two nodes on    |
| `k3s_gitlab_agent_replicas`            | `null`                                    | Explicit replica count, overrides auto        |
| `k3s_gitlab_agent_rotate_token`        | `false`                                   | One-shot token rotation for all listed agents |
| `k3s_gitlab_agent_helm_wait`           | `true`                                    | Helm waits for the release                    |
| `k3s_gitlab_agent_helm_timeout`        | `5m`                                      | Helm timeout                                  |
| `k3s_gitlab_agent_config_list`         | `[]`                                      | Agents, see below                             |

`vars/main.yml` holds derived values: the API URL, name rules and the Secret
annotation keys.

### KAS address

The default is the main-domain form derived from the GitLab URL
(`wss://<host>/-/kubernetes-agent/`, `ws://` for an `http` URL). When KAS has
its own host, override it in the inventory:

```yaml
k3s_gitlab_agent_kas_address: "wss://kas.gitlab.knell.dev"
```

Set `k3s_gitlab_agent_kas_ca_cert` only for a private CA; a public certificate
(for example Let's Encrypt) needs none.

### Agents

```yaml
k3s_gitlab_agent_config_list:
  - name: my-app # agent name in GitLab and Helm release name
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
4. Installs the chart with `rbac.create: false`,
   `config.operational_container_scanning.enabled: false` (both would add
   cluster-wide RBAC), `config.secretName` and no token in the values.
5. Waits for all agentk replicas to be ready; on failure prints pod state,
   events and log lines, then fails.
6. Prints a summary per agent: id, created or reused, token
   created/reused/rotated, revoked count, other active token ids, targets.

## Token rotation

Run once with `k3s_gitlab_agent_rotate_token: true`, then set it back. For
every listed agent the role creates a new token, replaces the Secret, restarts
the deployment, waits for ready pods and revokes the agent's other active
tokens. GitLab allows two active tokens per agent; at the limit the role first
revokes the tokens that the Secret does not hold.

A run that fails between creating a token and writing the Secret leaves an
unused token in GitLab. The next run creates another one and lists the unused
ids under `other_active_tokens`; revoke them in GitLab or run a rotation.

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
  hosts: "{{ hosts_limit | default('all') }}"
  roles:
    - k3s_gitlab_agent
```

```bash
ansible-playbook playbooks/k3s_gitlab_agent.yml -i <inventory>
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
