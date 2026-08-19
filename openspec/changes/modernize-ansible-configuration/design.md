## Context

The active configuration currently mixes repository-specific settings with a
long copied reference configuration. The repository executes roles from its
source tree, installs collection dependencies under `./collections`, and uses
a custom callback under `./callback_plugins`. Several roles require normal OS,
mount, memory, hostname, and network facts, while `playbooks/ping_local.yml`
already demonstrates play-level minimal fact gathering.

## Goals / Non-Goals

**Goals:**

- Keep the active configuration concise and portable.
- Preserve collection, role, callback, skeleton, and color behavior.
- Improve controller output cleanliness and SSH execution behavior.
- Avoid deprecated or no-op Ansible settings.
- Eliminate Ruff cache use in the configured quality path.

**Non-Goals:**

- Removing `.ai/` or the role skeleton.
- Adding persistent fact caching.
- Changing host-key verification policy.
- Enabling `force_handlers` globally.
- Changing playbook or role fact requirements.

## Decisions

- Keep `collections_path = ./collections`: the repository is a collection, but
  local execution still needs to discover installed `kubernetes.core` and
  other collection dependencies from the source tree.
- Remove global `gather_subset = all`: normal fact gathering remains available,
  and play-level subsets remain authoritative for targeted playbooks.
- Set `interpreter_python = auto_silent`: automatic discovery remains enabled,
  but expected discovery notices do not obscure play output.
- Set `unparsed_is_failed = True`: malformed inventory is unsafe for deployment
  automation and should fail early.
- Set SSH `retries = 3` while retaining existing pipelining: transient remote
  failures receive bounded recovery without adding unbounded waits.
- Set `nocows = True` and remove the stale cowsay selection list: cowsay is
  cosmetic noise and the existing multiline list is not needed.
- Keep existing color values and commented alternatives exactly as an operator
  reference; color tuning remains a later explicit choice.
- Use Ruff `--no-cache` on both configured invocations rather than changing
  global environment behavior.

Alternatives rejected: persistent fact caching adds stale-data and cleanup
policy without measured need; `force_handlers` changes failure semantics;
global `gather_subset = min` risks missing facts used by existing roles; and
hard-coded SSH control paths are less robust than Ansible's hashed defaults.

## Risks / Trade-offs

- [Strict inventory parsing] Local exploratory runs with intentionally partial
  inventory may fail earlier -> use an explicit alternate configuration or
  command-line override when needed.
- [SSH retries] Unreachable hosts take longer to fail -> the retry count is
  bounded at three and applies only to connection retries.
- [Silent interpreter discovery] A warning is suppressed -> discovery failures
  still fail the task and remain visible as errors.
- [Removed global `gather_subset`] A role that depended on an uncommon fact
  may expose the dependency -> normal default gathering is retained and
  existing role fact usage is covered by targeted validation.

## Migration Plan

1. Replace `ansible.cfg` with the concise active configuration.
2. Add `--no-cache` to both Ruff commands and remove `ansible.cfg.new`.
3. Inspect `ansible-config dump --only-changed` and run configured quality checks.
4. Roll back by restoring the prior three files if a deployment-specific
   behavior is incompatible.
