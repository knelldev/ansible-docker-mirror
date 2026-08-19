## Why

The role can create and update runners but does not provide a complete lifecycle
view or a safe reset path, and stale managed instance runners remain by default.
Operators also need nominal-memory-aware T-shirt selection and one concise final
account of what the role selected, reused, changed, removed, and verified.

## What Changes

- **BREAKING**: Enable stale GitLab runner cleanup by default when T-shirt runner
  generation is enabled; an explicit cleanup override can still disable it.
- Restrict automatic cleanup to `instance_type` runners carrying both the exact
  role management tag and an effective role-owned description prefix.
- Preserve project, group, unmarked manual, and supplied-token runners.
- Follow GitLab pagination so cleanup and reset are not limited to the first 100
  visible instance runners.
- Add an explicit force-reset flag, disabled by default, that deletes all matching
  managed instance registrations, clears saved values for desired API-managed
  instance runners, and recreates them through the normal flow.
- Keep Helm releases in place during reset and update them with newly resolved
  runner credentials.
- Apply a hybrid nominal-memory allowance equal to the greater of 512 MiB or 5
  percent of a T-shirt threshold, so normal virtualized memory overhead does not
  exclude an otherwise matching size.
- Print one secret-safe successful-run summary covering selection, cleanup/reset,
  identity, configuration, capacity, and observed health outcomes.

## Capabilities

### New Capabilities

- `k3s-runner-lifecycle`: Guarded instance-runner discovery, stale cleanup, and
  opt-in reset and recreation behavior.
- `k3s-runner-sizing`: Nominal-memory-aware eligibility for generated T-shirt
  runner sizes.
- `k3s-runner-deployment-summary`: Secret-safe end-of-role reporting for runner
  selection and lifecycle outcomes.

### Modified Capabilities

- None. Related K3s runner capabilities have not yet been synchronized into
  `openspec/specs/`, so this umbrella change introduces focused delta
  capabilities instead of modifying an accepted main spec.

## Impact

- Affected paths: `roles/k3s_gitlab_runner/tasks/`, role defaults or internal
  variables, and `roles/k3s_gitlab_runner/README.md`.
- GitLab instance-runner list and delete APIs are used with the existing admin
  credential; no new external system, collection, or dependency is introduced.
- Existing T-shirt deployments can remove stale role-owned instance runners on
  the next run unless cleanup is explicitly disabled.
- Reset removes GitLab registrations and target-side saved runner values but does
  not delete Helm releases, namespaces, project runners, or group runners.
- Successful playbook output gains one structured summary.

## Exclusions

- Deleting unmarked or manually managed instance runners.
- Deleting project or group runners under cleanup or reset.
- Resetting supplied-token runners whose GitLab registration is not role-owned.
- Deleting Helm releases, namespaces, job pods, cache data, or hook scripts.
- Persisting run history or querying external systems solely to enrich output.
- Printing credentials, rendered Helm values, secret content, or credential URLs.

## Risks

- Default cleanup is destructive for stale runners that satisfy both ownership
  markers. Type checks, exact tag checks, prefix checks, desired-state checks, and
  full candidate accounting must all pass before deletion.
- An overly broad reset could affect unrelated runners. Reset uses the same
  instance-type and dual-ownership boundary and remains disabled by default.
- Clearing saved values removes the only local copy of an authentication token.
  The role must complete discovery, require API credentials, and clear only
  desired API-managed instance state so normal recreation can resolve a token.
- Memory allowance can select a larger profile near a boundary. It is bounded by
  a fixed 512 MiB floor or 5 percent and affects eligibility only.
- Summary facts can leak between loop iterations unless each record is normalized
  and appended before the next runner starts.

## Simpler Alternatives Considered

- Keeping cleanup opt-in was rejected because generated T-shirt runners are fully
  role-owned and should converge automatically; an explicit disable remains.
- Deleting every visible instance runner was rejected because visibility is not
  ownership and would destroy manual infrastructure.
- Deleting Helm releases during reset was rejected because updating the existing
  release with a new token is sufficient and less disruptive.
- Limiting discovery to `per_page=100` was rejected because “all managed” must not
  silently depend on fleet size.
- Extending the stdout callback was rejected because lifecycle facts belong to
  this role and callback changes would affect unrelated playbooks.

## Approval

- Planning scope, nominal-memory allowance, managed-instance-only reset, and
  replacement of the prior summary-only plan were approved by the user on
  2026-08-19.
- Implementation was explicitly approved by the user on 2026-08-19.
- The hybrid 512 MiB or 5 percent allowance replaced the initial 5 percent-only
  rule after live 6 GB guest evidence and was approved on 2026-08-19.
