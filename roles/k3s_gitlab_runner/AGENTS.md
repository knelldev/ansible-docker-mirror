# k3s_gitlab_runner Role

## Purpose

Deploy and configure GitLab Runner on a K3s Kubernetes cluster via Helm.

## Local Contracts

- Follows the role layout in [`roles/AGENTS.md`](../AGENTS.md) but deviates from the container pattern: this is a Helm/Kubernetes deployment, not Podman/Quadlet.
- Variables prefixed `k3s_gitlab_runner_*`
- Cluster-only: run against K3s servers (controllers). Cluster work runs once
  (run_once); an early run_once assert in `01-prepare-k3s.yml` fails when that
  host has no kubeconfig. Root disk and memory facts of the play hosts feed
  the sizing.
- Hook scripts live in ConfigMap `runner-scripts` in the runner namespace,
  rendered from `pre-build.sh.j2`/`post-build.sh.j2` (`configmap.yaml.j2`).
  Job pods mount it read-only at `/opt/gitlab-runner/scripts` and run the
  hooks with `sh` (ConfigMap files have no exec bit). No host paths.

### Task Structure (4 numbered task files + utility)

1. `00-prepare.yml` — the shared data directories
2. `01-prepare-k3s.yml` — kubeconfig assert, runner namespace
3. `02-prepare-host.yml` — root filesystem capacity fact for storage sizing
4. `10-install.yml` — sizing, GitLab lifecycle, hook ConfigMap, Helm releases

### Utility Files (Not Auto-Discovered)

- `register.yml` — shared custom and T-shirt runner registration/deployment flow

## Work Guidance

### Run

```bash
ansible-playbook playbooks/k3s_gitlab_runner.yml -i <inventory> --limit <controller group>
```

### Post-Run

1. Verify runner registered in GitLab UI
2. `kubectl get pods -n gitlab-runner` — pods running
3. Test runner connectivity with a simple job

## Verification

```bash
ansible-playbook --syntax-check playbooks/k3s_gitlab_runner.yml
ansible-lint roles/k3s_gitlab_runner/
kubectl get pods -n gitlab-runner
```

## Child DOX Index

None.
