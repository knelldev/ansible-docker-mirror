# os_k3s Role

## Purpose

Install and configure K3s Kubernetes cluster on Linux hosts.

## Local Contracts

- Follows standard `os_*` role layout defined in [`roles/AGENTS.md`](../AGENTS.md)
- Variables prefixed `os_k3s_*`
- Deviates from the default 3-file pattern: `10-install.yml`, `11-configure.yml`, `20-helm.yml`
- Standard play runs install K3s and Helm only; node-type-specific installation lives in **utility files**

### Utility Files (Not Auto-Discovered)

Explicitly included per node role:

- `k3s-server.yml` — control-plane node install
- `k3s-agent.yml` — worker node install
- `k3s-dashboard.yml` — Kubernetes dashboard install

## Work Guidance

### Run

Server nodes:

```bash
ansible-playbook playbooks/os_k3s.yml -i <inventory> --tags server
```

Agent nodes:

```bash
ansible-playbook playbooks/os_k3s.yml -i <inventory> --tags agent
```

### Post-Run

1. `kubectl get nodes` — cluster healthy
2. `helm version` — Helm installed
3. Test cluster DNS and networking

## Verification

```bash
ansible-playbook --syntax-check playbooks/os_k3s.yml
ansible-lint roles/os_k3s/
kubectl get nodes
helm version
```

## Child DOX Index

None.
