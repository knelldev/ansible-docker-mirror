## Context

The existing `register.yml` mixes lookup, creation, rotation, rendering, and
deployment while relying on undocumented lookup filters and response state.

## Design

1. Normalize custom and T-shirt definitions into a shared loop with one resolved-token fact.
2. A supplied runner authentication token skips GitLab API calls. API-managed creation uses `POST /user/runners` and stores the returned token in target-side values.
3. Reuse existing target-side values as managed state on reruns. If managed state is missing, find the exact runner description and rotate its token; create a runner only when no exact match exists.
4. Render values from the resolved token before Helm, persist them with mode `0600`, and pass the rendered values directly to Helm.
5. Filter T-shirt definitions by enabled state and the minimum target-node memory. Compute capacity from non-negative usable memory.
6. Deploy optional hook scripts on every target before Helm, using the configured application path in the hostPath mount.
7. Verify first install, unchanged rerun, values recovery, supplied-token deployment, API-managed creation, chart rollout, runner visibility, and a real job pickup.

## Exclusions

- No GitLab MCP or unmanaged API credential storage.
- No broad runner-list lookup; recovery uses an exact description match and rotates only when managed state is missing.
- No cluster-wide K3s redesign.

## Risks

- GitLab API permissions and runner ownership differ by scope and version; API creation requires a `create_runner`-scoped credential.
- Token values must not appear in logs, artifacts, or committed files.
- Integration validation requires an authorized GitLab and K3s test environment.
