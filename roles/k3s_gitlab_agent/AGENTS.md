# k3s_gitlab_agent Role

## Purpose

Register GitLab agents for Kubernetes and deploy agentk on K3s via Helm, with
namespace-scoped RBAC only.

## Local Contracts

- Follows the role layout in [`roles/AGENTS.md`](../AGENTS.md); a Helm/Kubernetes
  deployment like `k3s_gitlab_runner`, sharing nothing with it at runtime.
- Variables prefixed `k3s_gitlab_agent_*`.
- The agent token exists only in Secret `<name>-token` in the agent namespace.
  It never goes into Helm values, task output or files on the target; every
  task that sends the API token or handles the agent token uses `no_log`.
- Cluster-only: run against K3s servers (controllers). An early run_once
  assert in `05-validate.yml` fails when the run_once host has no kubeconfig.
- The Helm values file lives only on the host that runs Helm (run_once), at
  `{{ app_path }}/<name>/values.yaml`, passed via `values_files`; no other
  host paths. `00-prepare.yml` only creates `app_path`.
- Chart values keep `rbac.create: false` and
  `config.operational_container_scanning.enabled: false`. Rights come only from
  Roles/RoleBindings per target namespace.
- No version pins in defaults: empty chart version means latest, empty image
  tag means the GitLab server version. Pins are inventory overrides.
- No `set_fact`: derived values are lazy expressions in `vars/main.yml`;
  manifests and summaries are templates. Values over runtime results stay
  plain expressions or `dict(...)`, never dict/list literals, so the shared
  `__REQUIRED__` check can template them before those results exist.
- Check mode is not supported.

### Task Structure

1. `00-prepare.yml` — `app_path` only; `05-validate.yml` — kubeconfig and input checks
2. `10-install.yml` — Helm repo, server version, nodes, per-agent loop, summary

### Utility Files (Not Auto-Discovered)

- `agent.yml` — per-agent registration, token Secret, RBAC, Helm, rotation
- `health.yml` — rollout wait with failure diagnostics

## Work Guidance

### Run

```bash
ansible-playbook playbooks/k3s_gitlab_agent.yml --limit <controller group>
```

### Post-Run

1. Agent connected in GitLab (Operate > Kubernetes clusters).
2. `kubectl get pods -n gitlab-agent-<name>` — pods ready.
3. No ClusterRoleBinding names `<name>-agentk`.

## Verification

```bash
ansible-playbook --syntax-check playbooks/k3s_gitlab_agent.yml
ansible-lint roles/k3s_gitlab_agent/ playbooks/k3s_gitlab_agent.yml
yamllint roles/k3s_gitlab_agent/ playbooks/k3s_gitlab_agent.yml
```

After a chart version bump, render the chart with the role's values
(`helm template`) and confirm it still has no ClusterRole or
ClusterRoleBinding.

## Child DOX Index

None.
