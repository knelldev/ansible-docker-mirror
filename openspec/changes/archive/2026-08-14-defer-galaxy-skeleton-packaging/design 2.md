## Context

The skeleton path is misconfigured, its variable contract contradicts generated
static legal text.

## Decision

- Keep the work out of runtime recovery and do not treat it as shippable.
- Start a new OpenSpec change only after confirming namespace, identity,
  copyright holder, license, packaging layout, and supported Ansible versions.
- The future change must verify generated role output and collection build/sanity behavior.

## Verification

- Confirm deferred artifacts are not referenced by current runtime deployment.
- Record the future entry criteria in the task list.
