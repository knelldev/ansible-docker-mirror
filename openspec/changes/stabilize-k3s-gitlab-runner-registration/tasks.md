## Status

- Approval: implementation approved on 2026-08-14.
- Blocker: controlled GitLab and K3s integration validation is unavailable locally.

## Tasks

- [x] Inventory current runner inputs, templates, API usage, and target-side state.
- [x] Verify authoritative API and Kubernetes collection contracts.
- [x] Define API-credential and supplied-runner-token paths.
- [x] Refactor registration around a normalized runner input, resolved token, and render-before-Helm flow.
- [x] Add target-side values reuse, restrictive secret permissions, T-shirt eligibility filtering, and pre-Helm all-host hook deployment.
- [ ] Run controlled GitLab API, Helm/K3s, runner-visibility, and job-pickup verification.
- [x] Record static validation and remaining integration evidence.

## Next Action

- Run controlled integration verification with a `create_runner`-scoped GitLab credential and a K3s cluster.
