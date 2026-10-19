## Context

The role deploys the GitLab Runner Helm chart into K3s and creates ephemeral Kubernetes executor job pods. T-shirt runners are derived from the smallest node memory and already receive generated size tags, resource limits, and priority behavior. The cluster is disposable; persistent state is intentionally limited to external S3 cache data.

## Design

### Readiness and diagnostics

Use the Helm module's bounded wait behavior, then query the release and runner manager pods through Kubernetes modules or controlled Kubernetes CLI calls already available to the role. On failure, gather status, events, and a bounded log tail before raising the failure. Use the GitLab API online check only for API-managed runners because runner authentication tokens cannot substitute for API credentials.

### Ownership and cleanup

Generate a stable role-owned description prefix and append the exact short `ansible` tag to generated T-shirt and custom runner tags. Compute desired managed descriptions from the current Ansible configuration. Cleanup remains opt-in and requires both markers; Kubernetes releases are never pruned.

### Replica calculation

Query schedulable Kubernetes nodes and calculate `min(node_count, 2)` unless the operator supplies an override. Feed the result into the runner Helm values. Apply soft pod anti-affinity and a one-replica PDB only for the two-replica case.

### Ephemeral storage

Keep storage sizing disabled by default. When enabled, derive a per-job budget from the lowest node disk capacity minus `max(20GiB, 20 percent)` and divide by runner concurrency. Apply a configurable per-size upper bound. The implementation must verify the supported GitLab Runner TOML fields before rendering them and must not create PVCs or persistent workspace host paths.

### Hooks and metrics

Extend the existing POSIX hooks rather than introducing a collector. Keep the current readable report and sizing recommendation. Add best-effort disk measurements, a single compact `RUNNER_METRICS` line, and configurable interval/threshold values. Measurements must never fail a CI job.

### Cache secret and Prometheus options

Preserve inline S3 cache configuration for compatibility. The active chart supports mounting additional Secrets for runner processes but does not expose a verified S3 cache credential reference, so no unused Secret option is added. Metrics exposure and `ServiceMonitor` creation are independent opt-in settings; neither is required for a normal deployment.

## Compatibility and Risks

- Existing defaults preserve hooks, T-shirt tags, non-privileged execution, latest Helm behavior, `run_untagged`, and optional S3 cache.
- Replica and PDB resources are additive and automatically limited to multi-node clusters.
- Cleanup is disabled by default and protected by two ownership markers.
- Disk calculations depend on reliable node filesystem facts; unavailable or invalid facts must leave the optional feature disabled or fail clearly rather than inventing a limit.
- Prometheus and Secret support must be validated against chart values and Kubernetes API behavior before implementation is considered complete.

## Exclusions

- GitLab Kubernetes Agent installation or project deployment RBAC.
- Kubernetes release cleanup from Ansible inventory drift.
- Shared Docker-in-Docker runners.
- PVCs, storage classes, or a persistent workspace.
- Helm chart pinning, autoscaling, and automatic runner-size changes.
