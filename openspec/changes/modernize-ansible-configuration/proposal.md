## Why

The repository configuration contains a large inherited Ansible example block,
an unnecessary explicit `gather_subset = all`, and cache-producing Ruff
commands. A concise, current configuration will preserve the repository's
collection and role execution behavior while making paths, performance,
output, and safety policies explicit.

## What Changes

- Replace the active `ansible.cfg` overrides with a concise repository-local configuration.
- Preserve the existing callback, path, and color behavior while retaining commented color reference options.
- Remove the global `gather_subset = all` override and retain play-level fact minimization where appropriate.
- Enable silent automatic remote Python interpreter discovery.
- Fail on unparseable inventory sources and retry transient SSH connection failures.
- Disable cowsay output while keeping deprecation warnings visible.
- Keep the local collection path because the source tree executes installed collection dependencies.
- Run Ruff without reading or writing its cache.
- Remove the obsolete `ansible.cfg.new` draft.

## Capabilities

### New Capabilities

- `modern-ansible-runtime-configuration`: Defines observable repository defaults for Ansible execution, collection discovery, output, and connection behavior.

### Modified Capabilities

- None.

## Impact

- Affects `ansible.cfg`, `scripts/quality.sh`, and the obsolete `ansible.cfg.new` file.
- Changes global fact gathering, interpreter warning, inventory parsing, SSH retry, and cowsay behavior.
- Does not add dependencies or change collection metadata, role skeleton support, or playbook contracts.
- Approval status: approved by the user in the current session with “go”.
