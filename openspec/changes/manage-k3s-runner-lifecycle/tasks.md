## 1. Defaults And Derived State

- [x] 1.1 Make stale cleanup follow T-shirt enablement by default, add the false-by-default managed instance reset flag, and document explicit overrides.
- [x] 1.2 Derive the effective ownership prefix and desired API-managed instance runner names without adopting compatibility-mode custom or supplied-token runners.
- [x] 1.3 Apply the hybrid 512 MiB or 5 percent allowance to smallest-host T-shirt eligibility without changing resource or capacity calculations.
- [x] 1.4 Initialize selected/excluded size, lifecycle count, and per-runner summary state before destructive or runner processing begins.

## 2. Guarded Discovery And Reset

- [x] 2.1 Implement complete paginated `instance_type` discovery with required API credentials and fail before deletion when any page is unavailable or malformed.
- [x] 2.2 Build cleanup/reset candidates using exact runner type, management tag, effective description prefix, and desired-state predicates.
- [x] 2.3 Implement opt-in reset that clears saved values only for desired API-managed instance runners, deletes all owned instance registrations, and preserves supplied-token, project, group, and unrelated target state.
- [x] 2.4 Confirm the normal registration flow recreates deleted runners, recovers safely after partial reset failure, and updates Helm releases in place.

## 3. Cleanup And Summary

- [x] 3.1 Replace single-page stale cleanup with complete guarded instance cleanup and record non-secret removed counts.
- [x] 3.2 Classify and append one secret-safe identity, configuration, health, capacity, and resource record at the end of each successful runner iteration.
- [x] 3.3 Print one structured successful-run summary after cleanup with cluster, sizing, feature, cleanup, reset, per-runner, and aggregate outcomes.
- [x] 3.4 Confirm lifecycle or runner failures preserve existing diagnostics and do not print a misleading successful summary.

## 4. Documentation And Local Validation

- [x] 4.1 Update the role README with default cleanup behavior, ownership boundaries, reset procedure, memory tolerance, summary fields, and the requirement to disable reset after use.
- [x] 4.2 Validate pagination flattening, ownership filtering, default/override cleanup behavior, missing-credential failures, reset target selection, and partial-failure recovery without live credentials.
- [x] 4.3 Validate fixed and proportional memory boundaries and all summary identity, configuration, lifecycle, and health classifications without rendering secrets.
- [x] 4.4 Run role `ansible-lint`, task-file `yamllint`, playbook syntax, rendered-output checks, and `git diff --check`.
- [x] 4.5 Re-read the applicable DOX chain and update durable contracts only if implementation changes their long-lived guidance.

## 5. Operator Validation

- [x] 5.1 Run Semaphore on the 6 GB target with reset disabled; verify `xs`, `s`, and `m`, inspect default stale cleanup, and capture the final summary.
- [x] 5.2 Run one unchanged pass and verify reused/unchanged classifications and zero unintended deletions.
- [ ] 5.3 Enable reset for one pass, verify only managed instance runners are recreated and Helm releases remain, then immediately disable reset.
- [ ] 5.4 Run a final reset-disabled pass and record stable online runners, cleanup counts, and summary evidence.

## Status

- Status: Reset-disabled runs validated; detail-aware administrator discovery is locally validated.
- Blockers: Corrective detail-aware live reset and final stability runs remain pending.
- Verification evidence: Targeted Ansible evaluations passed for pagination flattening, ownership and supplied-token filtering, cleanup defaults/override, expected missing-credential failure, reset snapshot refresh, all summary outcome labels, fixed allowance boundaries at 5631/5632 MiB, proportional boundaries at 33075/33076 MiB, and 5660 MiB `xs`/`s`/`m` selection with 6172 MiB eligibility memory. Role ansible-lint, changed-file yamllint, playbook syntax, rendered Helm values, Prettier, strict OpenSpec validation, and `git diff --check` pass. The full repository quality script remains red from 188 pre-existing ansible-lint findings outside `k3s_gitlab_runner`; its retained log contains no finding for this role. Initial live evidence at 5660 MiB motivated the hybrid rule. The revised reset-disabled live run selected `xs`, `s`, and `m`; reused unchanged online `xs` and `s`; created initial online `m`; pruned zero; and reset zero. The following unchanged live run reported three reused and unchanged runners with no unintended deletion. The first reset run cleared saved state and recreated three online runners but removed zero existing registrations, proving `/runners` did not provide complete administrator-wide discovery; lifecycle discovery now uses `/runners/all`. An accidental rerun before that commit stopped on the first runner before rotation because the existing folded reset-token URL inserted a control space; URL construction is now concatenated explicitly. The next recovery run reached GitLab successfully and returned the documented 201 token-reset response, but the role still expected 200 and stopped before saving the token; no additional registration was created. A subsequent reset rotated three existing runners but removed zero, proving list responses omit `tag_list`; local detail-response filtering now selects only prefix-matching instance runners with the exact `ansible` tag.
- Approved scope changes: User approved the hybrid 512 MiB or 5 percent nominal-memory allowance, default T-shirt stale cleanup, managed-instance-only reset, final summary, and replacement of the prior summary-only plan on 2026-08-19.
- Next action: Run one corrective detail-aware reset, then immediately disable reset.
