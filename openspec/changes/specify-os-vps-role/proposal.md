## Why

`roles/os_vps/` has a contract stub but no implementation or playbook. Its
intended tuning and hardening behavior needs an explicit, bounded plan.

## Outcome

Define a safe VPS baseline covering system tuning, monitoring integration, and
security settings without assuming one provider or distribution.

## Scope

- Define supported OS families and host capabilities.
- Define opt-in tuning categories and rollback behavior.
- Define monitoring and security boundaries.
- Define verification and idempotence requirements.

## Exclusions

- No implementation, package additions, or provider integrations in planning.
- No opinionated firewall, kernel, or monitoring changes before approval.

Risks include provider-specific kernels, performance regressions, and locking
out administrators. Defaults must therefore be conservative and opt-in.

Approval status: planning only.
