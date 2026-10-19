## Why

CI jobs that deploy into the k3s lab today use a long-lived ServiceAccount
token and CA stored as CI variables (`KUBE_TOKEN`, `KUBE_CA`), made by hand per
project. The GitLab agent for Kubernetes (agentk) replaces that: the cluster
dials out to KAS, GitLab hands authorized jobs a kubeconfig, and no cluster
credential lives in GitLab. KAS 19.5.0 is enabled on the lab GitLab. Installing
and registering agentk needs a role, like the runner.

## What Changes

- Add `roles/k3s_gitlab_agent/` and `playbooks/k3s_gitlab_agent.yml`, a sibling
  of `k3s_gitlab_runner` (same Helm repo, kubeconfig and API-token pattern),
  not a mode inside it.
- Per configured agent: register it in its config project through the REST API
  when missing, create one agent token when the cluster holds none, keep that
  token only in a Kubernetes Secret, and install the `gitlab/gitlab-agent` Helm
  chart (pinned chart version and agentk image tag) pointing at that Secret.
- Turn the chart's cluster-wide RBAC off (`rbac.create`, a ClusterRoleBinding,
  default `cluster-admin`; and operational container scanning, which the chart
  enables by default with its own ClusterRole and ClusterRoleBinding) and grant the agent's ServiceAccount a Role and RoleBinding
  per listed target namespace instead, with rules or a referenced ClusterRole
  given per namespace. Nothing cluster-wide by default.
- Derive the KAS address from the GitLab URL
  (`wss://<host>/-/kubernetes-agent/`), overridable; optional CA PEM for KAS.
- Optional one-shot token rotation flag: create a new token, update the
  Secret, roll the deployment, revoke the old token.
- Health: Helm wait, ready agentk pods, failure diagnostics, a secret-safe
  summary.

## Capabilities

### New Capabilities

- `k3s-gitlab-agent`: registration, token handling, namespace-scoped RBAC and
  Helm deployment of agentk on K3s.

### Modified Capabilities

- None.

## Impact

- New role, playbook, role README/AGENTS, `roles/AGENTS.md` index, root README
  playbook list.
- External: GitLab REST API (`/projects/:id/cluster_agents`), chart pull from
  `charts.gitlab.io`, agentk image from `registry.gitlab.com`, outbound
  websocket from the cluster to KAS. `k3s_gitlab_runner` is unchanged.

## Scope Boundary And Exclusions

- No agent config file (`.gitlab/agents/<name>/config.yaml` with `ci_access`):
  it lives in the config project's repository and is that project's change.
- No GitLab server settings (`gitlab.rb` KAS URLs), proxy allowlist or DNS.
- No `access_as` impersonation: Premium/Ultimate only. On Free, CI jobs inherit
  the agent ServiceAccount's rights, so the per-namespace Role is the boundary.
- No GitOps/Flux, no observability or operational container scanning.
- No cleanup of agents removed from the inventory (listed in the design as a
  later option).
- No live deployment in this change without separate approval.

## Alternatives And Risks

- A mode switch in `k3s_gitlab_runner`: about 80% of that role (T-shirt sizing,
  hooks, PriorityClass, runner pagination, cleanup, token rotation via
  `/user/runners`) does not apply to agentk, so nearly every task would carry a
  mode condition. Rejected; shared code can be extracted later if a third
  GitLab-on-K3s role appears.
- Keep `KUBE_TOKEN`/`KUBE_CA`: works today, no new moving part, but every
  project needs a hand-made token and CA in GitLab. Kept as the fallback.
- Chart RBAC with `rbac.useExistingRole`: still a ClusterRoleBinding, so a
  namespaced intent becomes cluster-wide. Rejected.
- Risk: on Free every authorized project gets all of the agent's rights. Mitigation:
  one agent per trust boundary, `ci_access` limited to named projects,
  environments and protected branches (set in the config project).
- Risk: the token is returned only once by the API. Mitigation: the Secret is
  written in the same run; if the run fails between creation and the Secret,
  the next run creates a second token (limit two active) and the summary
  names the orphan to revoke.
- Risk: agentk version must match GitLab major.minor (±1 minor). Mitigation:
  image tag pinned in defaults next to the chart version.

Approval status: approved by the user on 2026-10-18 to build with offline
checks only (lint, syntax check, `helm template`). Not approved: git commit,
push, and any run against a real cluster or the GitLab API (tasks 2.4 and 2.5
need separate approval).
