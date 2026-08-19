## Tasks

- [x] Inspect installed GitLab Runner chart values and repository module support for readiness, replicas, PDB, metrics, secrets, and ephemeral-storage fields. Evidence: `kubernetes.core` 6.5.0; chart documentation confirms `replicas`, `metrics.serviceMonitor`, `affinity`, `podDisruptionBudget`, and manager `resources`; Helm CLI is unavailable locally.
- [x] Add defaults and derived variables for `ansible` ownership markers, health timeouts, automatic replicas, optional cleanup, hook settings, storage sizing, cache Secret handling, and Prometheus options.
- [x] Update runner registration to append the ownership tag consistently while preserving generated T-shirt tags, custom tags, and `run_untagged` behavior.
- [x] Implement bounded Helm/Kubernetes readiness checks and failure diagnostics, plus optional GitLab API online verification.
- [x] Implement opt-in GitLab stale-runner cleanup guarded by exact tag and description prefix; never remove Kubernetes releases or unmarked runners.
- [x] Add automatic multi-node replica calculation, soft anti-affinity, and conditional PDB resources.
- [x] Validate S3 cache Secret handling and rendered chart values without exposing credentials in task output. Evidence: active chart values expose mounted `secrets` but no verified S3 cache credential reference; inline cache behavior remains unchanged rather than adding an unused option.
- [x] Add optional automatic ephemeral-storage sizing from lowest-node disk capacity, buffer, concurrency, and T-shirt bounds without persistent workspace storage.
- [x] Extend pre/post hooks with best-effort disk measurements, configurable sampling, configurable thresholds, and one compact `RUNNER_METRICS` line.
- [x] Add optional runner-manager metrics service and conditional `ServiceMonitor`.
- [x] Update role README and applicable DOX documentation with the final variables, ownership behavior, exclusions, and verification steps.
- [x] Run syntax, ansible-lint, yamllint, rendered-template checks, and targeted Kubernetes/Helm validation. Evidence: playbook syntax and ansible-lint pass; yamllint reports existing comment-spacing warnings; `git diff --check` passes; live Helm render unavailable because `helm` is not installed; live K3s validation remains intentionally pending for operator testing.
