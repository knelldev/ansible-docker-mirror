## Context

The role exists under `roles/con_watchtower/` but no current playbook invokes
it. Existing container roles use rootless Podman and Quadlet; Watchtower's
actual runtime must be verified before a support decision.

## Decisions Required

- Keep the role as supported opt-in automation or retire it.
- Define image update policy, labels, maintenance windows, and rollback.
- Define whether the role gets a dedicated playbook and operational checks.
- Update README and TECHSTACK only after the decision is accepted.

## Verification Shape

Evidence must include repository reference search, rendered unit inspection,
and a controlled update/rollback test if the role remains supported.
