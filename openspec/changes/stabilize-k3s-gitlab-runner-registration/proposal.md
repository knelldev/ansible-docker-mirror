## Why

The current registration flow can skip manual-token deployments, read values
before writing them, and use unverified GitLab API lookup and scope behavior.
It cannot safely deploy runners needed soon.

## What Changes

- Consolidate custom and T-shirt runners into one registration and deployment flow.
- Resolve one runner authentication token before rendering values and deploying Helm.
- Persist target-side managed values with restrictive permissions and reuse them on unchanged reruns.
- Support supplied runner authentication tokens and API creation through the documented user runner endpoint.
- Filter T-shirt sizes by the smallest target node's available capacity.

## Capabilities

### New Capabilities

- `k3s-gitlab-runner-registration`: K3s runner deployments consistently resolve registration credentials and deploy Helm values.

### Modified Capabilities

- None.

## Impact

- `roles/k3s_gitlab_runner/`, GitLab REST API usage, Helm releases, and K3s runner workloads.
- External GitLab and Kubernetes systems require controlled integration verification.

## Alternatives And Risks

- Manual-token-only deployment is simpler but does not meet API-managed token rotation needs.
- API creation requires a `create_runner`-scoped credential and target scope ownership; GitLab API integration still needs controlled-environment verification.
- Approval status: implementation approved on 2026-08-14; integration validation remains required before closeout.
