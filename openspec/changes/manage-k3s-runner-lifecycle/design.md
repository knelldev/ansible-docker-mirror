## Context

See `proposal.md` for motivation. The current role selects T-shirt runners before
the shared registration loop and performs optional stale cleanup afterward. Its
cleanup request reads one page, is disabled by default, and requires an explicit
description prefix. Saved per-runner `values.yaml` files contain the runner token
needed for safe reruns. The applicable constraints are in `TECHSTACK.md`,
`AGENTS.md`, `roles/AGENTS.md`, and `roles/k3s_gitlab_runner/AGENTS.md`.

## Goals / Non-Goals

**Goals:**

- Converge role-owned instance registrations without touching other runner types.
- Make reset recoverable if a destructive API sequence fails partway through.
- Build summary records from existing execution facts.
- Explain T-shirt selection at nominal memory boundaries.

**Non-Goals:**

- Taking ownership of manual, project, group, or supplied-token registrations.
- Deleting or reinstalling Helm releases during reset.
- Adding reporting-only API calls or persistent run history.
- Changing resources or capacity after a T-shirt size is selected.

## Decisions

### Resolve one effective ownership prefix

Keep the compatibility default for custom descriptions. When an explicit role
description prefix is configured, use it for ownership checks. Otherwise use the
existing generated T-shirt prefix `k8s-runner-`, which makes default cleanup own
generated T-shirts without adopting arbitrary custom descriptions. Every delete
also requires exact `instance_type` and management-tag matches.

Alternative: default the public description prefix to `k8s-runner-`. Rejected
because that would rename existing custom runners and can cause duplicates.

### Make stale cleanup follow T-shirt mode by default

Define the stale-cleanup default from `k3s_gitlab_runner_tshirt_enabled`, while
preserving an explicit inventory override. Cleanup remains after desired runner
processing and deletes only owned candidates absent from desired descriptions.

Alternative: keep cleanup opt-in. Rejected because generated T-shirt runners are
fully role-owned and should converge when host eligibility changes.

### Complete paginated discovery before deletion

Fetch the first administrator-wide `/runners/all` `instance_type` page with the
API maximum page size, read GitLab's pagination metadata, fetch every remaining
page, flatten results, and then build the owned candidate list. The narrower
`/runners` endpoint is not sufficient because it only exposes runners available
to the authenticated user. GitLab's list response also omits ownership tags, so
filter list results by the effective description prefix, read details only for
those candidates, and apply the exact management-tag check to detail responses.
Any discovery or required detail failure stops before deletion. Reset and normal
cleanup each use a candidate snapshot appropriate to their position in the run.

Alternative: use one 100-item page. Rejected because fleets above that boundary
would be partially converged without warning.

### Reset registration state but retain Helm releases

Add `k3s_gitlab_runner_reset_managed_instance_runners`, default false. Before the
normal runner loop, validate the admin credential and complete discovery. Build
the desired API-managed instance runner names, clear only their saved
`values.yaml` files, then delete every owned instance candidate. The normal flow
rotates any surviving registration after a partial deletion failure or creates a
missing registration, and updates the existing Helm release with the new token.

Supplied-token, project, and group runner saved values are excluded. Hook scripts,
cache data, namespaces, and stale unknown directories are not removed.

Alternative: uninstall Helm releases. Rejected because token replacement through
the existing Helm update path is sufficient and avoids extra disruption.

### Accumulate one safe record per runner

Initialize summary state before the include loop and append a complete normalized
dictionary at the end of each successful runner iteration. Identity precedence is
`supplied`, `created`, `rotated`, then `reused`; configuration precedence is
`forced`, `initial`, `updated`, then `unchanged`. Health uses completed GitLab or
Kubernetes results and otherwise says `not checked`.

After cleanup, print one structured debug payload with cluster, sizing, feature,
lifecycle, runner, and aggregate data. No callback change or `set_stats` output is
needed.

### Apply hybrid eligibility allowance

Compute one eligibility value as the greater of observed memory plus 512 MiB and
observed memory divided by 95 percent, then compare existing nominal thresholds
with that value. The fixed allowance handles normal low-memory VM overhead; the
percentage remains proportional at larger cutoffs. Keep all definitions and
post-selection calculations based on actual memory unchanged.

Alternative: lower each threshold or round all memory to a nominal GiB. Rejected
because the former duplicates policy and the latter can fail when large guests
lose more than 512 MiB to virtualization and kernel reservations.

## Risks / Trade-offs

- [Default cleanup removes a stale owned runner unexpectedly] -> Require complete
  discovery plus type, exact tag, prefix, and desired-state checks.
- [Reset fails after partial deletion] -> Clear only desired API-managed instance
  saved values after successful discovery so the next normal run can rotate
  surviving registrations and create missing ones.
- [Reset flag remains enabled] -> Document that every enabled run intentionally
  recreates managed instance registrations; keep the default false.
- [API pagination metadata is absent or malformed] -> Treat discovery as failed
  rather than assume one page is complete.
- [Summary overstates health] -> Report `not checked` without completed evidence.
- [Memory allowance admits an undersized host] -> Bound the fixed adjustment to
  512 MiB, retain the 5 percent proportional rule, and preserve all capacity and
  resource safeguards using actual memory.

## Migration Plan

1. Add lifecycle defaults, effective ownership facts, and credential assertions.
2. Implement full paginated instance discovery and guarded reset before runner
   processing.
3. Apply the hybrid memory allowance and initialize sizing and summary state.
4. Append runner records, run guarded stale cleanup, and print the final summary.
5. Update role documentation and validate locally.
6. Run once in Semaphore with reset disabled, inspect cleanup and summary, then
   perform a separate reset-enabled test and immediately disable the flag.

Rollback restores opt-in cleanup and exact memory thresholds and removes summary
output. It does not restore registrations deleted by a completed cleanup/reset or
remove Helm releases that became newly eligible.
