# k3s_gitlab_runner Role

## Purpose

Deploy and configure GitLab Runner on a K3s Kubernetes cluster via Helm.

## Local Contracts

- Follows the role layout in [`roles/AGENTS.md`](../AGENTS.md) but deviates from the container pattern: this is a Helm/Kubernetes deployment, not Podman/Quadlet.
- Variables prefixed `k3s_gitlab_runner_*`

### Task Structure (3 numbered task files + utility)

1. `00-prepare.yml` — system preparation
2. `01-prepare-k3s.yml` — K3s cluster-specific preparation
3. `10-install.yml` — GitLab Runner install via Helm chart

### Utility Files (Not Auto-Discovered)

- `register.yml` — shared custom and T-shirt runner registration/deployment flow

## Work Guidance

### Run

```bash
ansible-playbook playbooks/k3s_gitlab_runner.yml -i <inventory>
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
