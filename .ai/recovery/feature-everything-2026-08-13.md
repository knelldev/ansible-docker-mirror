# feature/everything Recovery Handoff

## Scope

- Repository: `/Users/knell/Documents/Development/ansible-docker`
- Branch: `feature/everything`
- Merge target: `develop`
- Remote state: branch contains `aef8580 chore: current state` and is one commit ahead of `origin/develop`.
- Safety rule: do not merge this branch into `develop` in its current state.
- Audit date: 2026-08-13

## Executive State

- Commit `aef8580` mixes 116 files, 3,374 additions, and 272 deletions.
- Uncommitted work also changes configuration, editor settings, AI policies, and documentation.
- Untracked files add callback code, a role skeleton, collection metadata, AI configuration, generated collection installs, and AI research residue.
- Current branch changes contain confirmed functional regressions. Treat it as forensic source, not a merge candidate.

## Confirmed Functional Blockers

### Role Vars Refactor

- Affected roles moved `vars/main.yml` to `vars/main/00-app.yml`.
- Paths include `roles/con_gitlab/vars/main/00-app.yml`, `roles/con_minio/vars/main/00-app.yml`, `roles/con_nginx/vars/main/00-app.yml`, `roles/con_semaphore/vars/main/00-app.yml`, `roles/con_watchtower/vars/main/00-app.yml`, `roles/os_container/vars/main/00-app.yml`, `roles/os_gitlab_runner/vars/main/00-app.yml`, `roles/os_k3s/vars/main/00-app.yml`, `roles/os_prepare/vars/main/00-app.yml`, `roles/pve_vm_clone/vars/main/00-app.yml`, `roles/win_container/vars/main/00-app.yml`, `roles/win_gitlab_runner/vars/main/00-app.yml`, and `roles/win_prepare/vars/main/00-app.yml`.
- Ansible automatically loads `vars/main.yml`, not arbitrary nested `vars/main/*.yml` files.
- Changed `tasks/main.yml` files only load operating-system-specific variables.
- Result: roles using `app_name` or `app_path` can fail at runtime.
- Recovery: restore `vars/main.yml` or explicitly load the nested file before any dependent task. Preserve the current behavior before considering a structural refactor.

### K3s GitLab Runner Registration

- Primary path: `roles/k3s_gitlab_runner/tasks/register.yml`.
- Manual token behavior is documented as skip API then deploy Helm.
- Current Helm task has `runner_item.token is not defined` in its condition.
- Result: manual-token runners never deploy.
- Current Helm values use `lookup('file', ('{{ app_path }}/' + ...))` before the subsequent task writes `values.yaml`.
- Result: first deployment fails; the lookup path also contains literal Jinja delimiters.
- API runner create/reset responses do not populate the variables read by `templates/values.yaml.j2` and `templates/values-tshirt.yaml.j2`.
- Result: API-created or rotated runner tokens do not reach Helm values.
- Current runner list uses `/api/v4/runners?runner_type=...&name=...`.
- GitLab runner listing documents `type`, not `runner_type`, and does not document `name` filtering. Pagination also makes broad list matching unsafe.
- Result: lookup, idempotency, duplicate prevention, and token rotation are unreliable.
- Group/project registration changed from scoped endpoints to `/api/v4/user/runners` without validated scope semantics.
- Recovery: isolate this feature. Define and test manual token, API token, admin token, create, existing runner, rotation, instance, group, project, pagination, unchanged rerun, changed values, and changed sizing paths. Render values before Helm and pass one resolved runner token into the templates.

## Configuration And Source Defects

### Callback Plugin

- `ansible.cfg` sets `stdout_callback = knelldev_default`.
- `callback_plugins/knelldev_default.py` declares `CALLBACK_NAME = "file_prefixed_default"` and documentation name `file_prefixed_default`.
- Result: configured plugin name and declared plugin name disagree.
- Intended callback behavior: prefix task and handler output with source paths.
- Recovery: choose one identifier, align configuration, Python metadata, and documentation, then run a real playbook to verify stdout output.

### Role Skeleton

- Source skeleton: `roles/.skeletons/role_skeleton/`.
- `ansible.cfg` points at `./.skeletons/role_skeleton`.
- Result: `ansible-galaxy role init` cannot find the repository skeleton from the root path.
- `roles/.skeletons/role_skeleton/AGENTS.md` and `README.md` claim unprefixed `app_*` variables.
- `defaults/main/10-install.yml.j2` generates role-prefixed variables.
- Result: skeleton contracts contradict generated source.
- `AGENTS.md` also claims templates are runtime-only while they retain `.j2` and init-sensitive Jinja behavior.
- Recovery: decide the generated variable contract first; then align files, docs, and `role_skeleton` path. Verify with `ansible-galaxy role init` plus linting of skeleton and generated role.

### Legal And Collection Metadata

- `LICENSE.md` contains unrendered Ansible Jinja. A root license must be static legal text.
- `meta/runtime.yml` declares `requires_ansible: ">=2.17.0"`.
- `galaxy.yml` retains placeholder identity and URLs.
- Recovery: keep collection metadata only if collection packaging is an approved scope. Otherwise remove or defer it. Replace the license only after the desired license and copyright owner are confirmed.

### Playbook And Inventory Migration

- Branch moves root playbooks into `playbooks/`.
- `ansible.cfg` changes default inventory from `./inventories/internal` to `./inventory`.
- Existing commands and automation may depend on root playbook paths and the old inventory path.
- README and other documentation drift from the new layout.
- Recovery: decide whether this is a compatibility-breaking layout migration. If yes, isolate it, update every documented command and pipeline, and include a migration note. If no, revert these changes.

## Verification Failures

| Check                                    | State                     | Evidence                                                                                                           |
| ---------------------------------------- | ------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `git diff --check origin/develop...HEAD` | Fails                     | New blank lines at EOF in `ansible.cfg.default` and `galaxy.yml`                                                   |
| `ansible-lint roles/k3s_gitlab_runner/`  | Fails                     | 23 violations; new indentation issue around `defaults/main/11-k3s-gitlab-runner.yml:83` plus existing quality debt |
| K3s syntax check                         | Passes only syntactically | Does not evaluate registration templates, GitLab API behavior, Helm inputs, or Kubernetes deployment               |
| GitLab API integration                   | Missing                   | No create, rotate, scope, lookup, or pagination coverage                                                           |
| Helm/K3s integration                     | Missing                   | No first install, rerun, values change, token rotation, or job pickup coverage                                     |

## Untracked Artifact Classification

| Path                                    | Classification                                        | Recommended action                                                                                    |
| --------------------------------------- | ----------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `.ansible/`                             | Generated Ansible cache; includes installed self-copy | Delete locally; add root ignore                                                                       |
| `collections/ansible_collections/`      | Generated installed FreeIPA collection tree           | Delete locally; add root ignore; retain only `collections/requirements.yml` as dependency declaration |
| `.opencode/node_modules/`               | Generated Node dependencies                           | Delete locally; `.opencode/.gitignore` already ignores it                                             |
| `.opencode/package.json` and lockfile   | Local OpenCode dependency setup                       | Do not commit unless repo-supported OpenCode tooling requires reproducible dependencies               |
| `.opencode/opencode.json`               | Repository OpenCode instruction and LSP config        | Keep only after separate policy review                                                                |
| `.ai/.tmp/automation-good-practices/`   | Cloned research cache                                 | Delete locally; ignore `.ai/.tmp/`                                                                    |
| `.ai/SESSION_FEEDBACK_*.md`             | Session residue                                       | Delete or move outside repository                                                                     |
| `.ai/SKELETON_TLDR.md`                  | Stale handoff material                                | Delete after durable skeleton contract is corrected                                                   |
| `.ai/AGENTS.template.md`                | Generic DOX template                                  | Move to a shared template location or delete unless actively used                                     |
| `callback_plugins/knelldev_default.py`  | Intended source                                       | Keep after callback identifier and behavior verification                                              |
| `callback_plugins/__pycache__/`         | Generated Python bytecode                             | Delete; root ignore already covers it                                                                 |
| `roles/.skeletons/role_skeleton/`       | Intended source                                       | Keep after contract and path repair                                                                   |
| `meta/runtime.yml`                      | Potential collection source                           | Keep only with approved collection packaging scope                                                    |
| `.github/instructions/`                 | AI client policy                                      | Keep only after simplifying overlapping agent instructions and confirming supported consumers         |
| `.github/prompts/techstack.template.md` | Workflow template                                     | Keep only if the TECHSTACK maintenance workflow remains approved                                      |
| `LICENSE.md`                            | Intended legal artifact                               | Keep only after static legal-content repair                                                           |

## AI Configuration Review

- OpenCode config path: `.opencode/opencode.json`.
- Current configuration enables repository instructions and language servers for YAML, Ansible, Python, shell, Terraform, and Markdown.
- It contains no MCP server, remote service, plugin, permission, or model settings.
- `.opencode/.gitignore` excludes its package manifest, lockfile, dependencies, and itself, leaving only `opencode.json` visible as a candidate source file.
- New `.github/instructions/architect.instructions.md`, `caveman.instructions.md`, and `workflow.instructions.md` overlap heavily.
- `workflow.instructions.md` has overlapping pre-flight/spec gates and requires tool-specific external memory behavior.
- `caveman.instructions.md` requires tables for every comparison, conflicting with concise operational output.
- `architect.instructions.md` adds audit behavior that overlaps workflow closeout requirements.
- Recovery: decide supported AI clients first. Retain one minimal, tool-agnostic repository policy. Put client-specific configuration outside the repository unless it is deliberately shared contributor tooling.
- If OpenCode configuration changes, validate against `https://opencode.ai/config.json` and restart OpenCode after changing config-time files.

## Workstreams To Split

1. `openspec/changes/establish-ai-governance/` — AI policy, generated artifacts, and ignore rules.
2. `openspec/changes/restore-role-vars-loading/` — Restore standard role variable loading.
3. `openspec/changes/stabilize-k3s-gitlab-runner-registration/` — K3s runner registration after API-contract confirmation.
4. `openspec/changes/repair-ansible-callback/` — Callback plugin behavior and related configuration.
5. `openspec/changes/decide-playbook-layout-migration/` — Retain or revert the playbook and inventory layout change.
6. `openspec/changes/defer-galaxy-skeleton-packaging/` — Deferred skeleton, collection metadata, and legal work.
7. Documentation and cosmetic cleanup only after retained runtime behavior is final.

OpenSpec change records are the canonical plan, task-state, blocker, and verification records. This handoff remains evidence for the mixed branch until recovery completes.

## Safe Recovery Sequence

1. Preserve `feature/everything` unchanged as forensic source.
2. Start a clean branch from current `origin/develop` for each retained workstream.
3. Remove generated artifacts and add narrow ignores before testing source changes.
4. Restore `vars/main.yml` behavior before running any role-level verification.
5. Decide whether to repair or discard the K3s runner work. Do not mix it with refactoring.
6. Validate GitLab API behavior from official documentation and a controlled GitLab test environment before implementing runner registration.
7. Repair callback and skeleton units independently.
8. Decide the playbook/inventory migration explicitly, including compatibility policy.
9. Reconcile documentation with final paths and behavior.
10. Require green `git diff --check`, `ansible-lint`, YAML linting, syntax checks, and applicable integration checks before merging any workstream to `develop`.

## Decisions Needed

1. Keep or discard the role vars refactor?
2. Keep or redesign K3s runner registration?
3. Is `playbooks/` plus `./inventory` an approved breaking migration?
4. Is Galaxy collection packaging in scope now?
5. Should OpenCode and GitHub AI instructions be committed contributor tooling or local-only tooling?
6. Which static license and copyright holder should `LICENSE.md` contain?

## Commands For Next Session

```bash
cd /Users/knell/Documents/Development/ansible-docker
git status --short
git log --oneline --decorate origin/develop..HEAD
git diff --check origin/develop...HEAD
git diff --check
ansible-lint roles/k3s_gitlab_runner/
ansible-playbook --syntax-check playbooks/k3s_gitlab_runner.yml
```
