## Context

- Repository contracts: `TECHSTACK.md`, `roles/AGENTS.md` (numbered tasks,
  `vars/main.yml` derivations, `__REQUIRED__` sentinels),
  `roles/k3s_gitlab_runner/` as the pattern for Helm on K3s and GitLab API use.
- Sources, fetched 2026-10-18:
  - API: https://docs.gitlab.com/api/cluster_agents/
  - Install: https://docs.gitlab.com/user/clusters/agent/install/
  - CI/CD workflow: https://docs.gitlab.com/user/clusters/agent/ci_cd_workflow/
  - Chart `main` (`Chart.yaml` 2.33.0 / appVersion v19.5.0, `values.yaml`,
    `templates/clusterrolebinding.yaml`):
    https://gitlab.com/gitlab-org/charts/gitlab-agent
- First consumer: `kube_01_cv` deploys its chart into namespace `kube-01-cv`
  from job `deploy-dev`; its `deploy/ci-deployer.yaml` lists the rules that
  deploy needs.

## Decisions

### Separate role

`k3s_gitlab_agent`, prefix `k3s_` like its sibling. Shared with the runner:
the `gitlab` Helm repo, kubeconfig and Helm binary paths, namespace creation,
the API token from vault, `no_log` on every credential task. Nothing is
imported from the runner role.

### Variables (sketch)

```yaml
k3s_gitlab_agent_gitlab_external_url: "{{ con_gitlab_external_url }}"
k3s_gitlab_agent_api_token: __REQUIRED__ # Maintainer, api scope (vault)
k3s_gitlab_agent_kas_scheme: wss # ws for an http URL
k3s_gitlab_agent_kas_host: <host of external url>
k3s_gitlab_agent_kas_port: "" # port of the URL, if any
k3s_gitlab_agent_kas_path: /-/kubernetes-agent/
k3s_gitlab_agent_kas_address: <built from the parts>
k3s_gitlab_agent_kas_ca_cert: "" # PEM, only for a private CA
k3s_gitlab_agent_chart_version: "" # latest; pin in the inventory
k3s_gitlab_agent_image_tag: "" # GitLab server version
k3s_gitlab_agent_monitoring: true
k3s_gitlab_agent_replicas_auto: true # 1 on one node, 2 on >= 2 (as the runner)
k3s_gitlab_agent_replicas: null
k3s_gitlab_agent_rotate_token: false # one-shot
k3s_gitlab_agent_config_list:
  - name: kube-01-cv # agent name = release name
    project: lukas/kube_01_cv # config project, path or id
    namespace: gitlab-agent-kube-01-cv # where agentk runs
    targets:
      - namespace: kube-01-cv
        rules: [...] # a Role, or:
        # cluster_role: edit                    # RoleBinding to a ClusterRole
```

Project path above is illustrative; the real one comes from the inventory.

### Registration and token

1. `GET /projects/:id/cluster_agents`; `POST` with `name` when absent.
2. Read Secret `<name>-token` in the agent namespace. Present and no rotation:
   reuse. Absent: `POST /projects/:id/cluster_agents/:agent_id/tokens` and
   write the `token` field into the Secret in the next task.
3. Rotation: create a new token, replace the Secret; the Secret's token id
   goes into the chart's `podAnnotations`, so Helm rolls the pods; wait
   ready, then `DELETE` every other active token of that agent.
4. The chart gets `config.secretName`, never `config.token`, so the token is
   not in Helm values or release records.

The Secret is the only token state. The chart values are rendered to
`{{ app_path }}/<name>/values.yaml` on the host (as the runner does, but
without the token) and passed via `values_files`.

The Secret carries the token id as annotation `gitlab.com/agent-token-id`, so
a rotation can keep that token and the summary can name other active tokens
(orphans). When a new token is needed at the two-token limit, the role first
revokes the tokens the Secret does not hold. GitLab API calls use the shared
`http.ssl_verify`, like the runner.

### RBAC

`rbac.create: false`. The chart's own ServiceAccount stays
(`serviceAccount.create: true`), with its name set explicitly to
`<name>-agentk` so the RoleBindings do not depend on the chart's fullname
helper.

Correction found while building (chart 2.33.0 rendered with `helm template`):
`rbac.create` is not the chart's only cluster-wide RBAC.
`config.operational_container_scanning.enabled` defaults to `true` and renders
a ClusterRole and a second ClusterRoleBinding (`templates/ocs/`). The role sets
it to `false` explicitly. With both off the chart renders only a
ServiceAccount, a Deployment and a Service (plus a ConfigMap when
`kasCaCert` is set). For each target namespace the role applies a
Role (from `rules`) and a RoleBinding to that ServiceAccount, or only a
RoleBinding to `cluster_role`. A target without `rules` or `cluster_role`
fails the run; so does a target with both (exactly one is required). The
RoleBinding for `cluster_role` carries the ClusterRole in its name because
`roleRef` is immutable. Whatever agentk needs in its own namespace (for example leases,
if it uses leader election) is granted there, found by task 2.4, not assumed.

### Agents, projects and namespaces

The list holds n agents, each with n target namespaces; `ci_access` in the
config project may authorize n projects or a group. On Free every authorized
project gets all of the agent's rights in all its target namespaces, so the
recommended shape is one agent per trust boundary (today: one per project).
No namespace wildcard: RBAC has none, and a pattern would need cluster-wide
rights to create namespaces. Wildcards belong in `ci_access.environments`
(for example `review/*`) in the config project.

### Replicas

Automatic like the runner manager: one replica on a one-node cluster, two on
clusters with at least two schedulable nodes, with soft anti-affinity.
A second pod on the same node only covers a crash of one pod; chart upgrades
already roll without a gap (a new pod starts before the old one stops), and a
node failure takes both. An explicit count overrides.

### Chart values

`config.kasAddress`, `config.secretName`, `config.kasCaCert` (when set),
`image.tag` (left out when empty), `replicas`, `rbac.create: false`,
`resources` (default `{}`), `podAnnotations` with the token id. Receptive
mode and OCS are set off explicitly. `config.observability.enabled` follows
`k3s_gitlab_agent_monitoring` (default on): off drops the metrics Service and
the chart's `prometheus.io/*` annotations; the probes on port 8080 keep
working. `serviceMonitor` stays off (needs the Prometheus operator CRD).

The KAS default is the main-domain form; the lab uses
`ws://10.0.10.25:8150`, set as parts in the inventory (README example).

### Health and output

`helm --wait`, then ready pods of the release; on failure the last log lines
and events (as the runner does). Summary: agent name, id, project, created or
reused, token created/reused/rotated, token id, revoked token ids, target
namespaces. No token.

### Check mode

Not supported: the house roles include tasks dynamically from `main.yml`.

## Open Points

- Open: whether the lab KAS at `ws://10.0.10.25:8150` (no TLS) is the final
  address, or a TLS address replaces it (then maybe `kas_ca_cert`).
- Later: prune agents and namespaces no longer listed.
