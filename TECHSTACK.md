# Project Tech Stack & Blueprint Matrix

> Binding reference for the `ansible-docker` workspace. All new roles, playbooks, collections, and CI artifacts MUST conform to the contracts below. **Version:** `v1.1.0` · **Verified:** 2026-08-13.
>
> See also: [AGENTS.md](./AGENTS.md) (root DOX rail) · [.github/prompts/techstack.prompt.md](./.github/prompts/techstack.prompt.md) (maintenance prompt) · [.github/prompts/techstack.template.md](./.github/prompts/techstack.template.md) (template source)

---

## Core Technology Stack

### Automation runtime

| Layer                  | Tool                   | Version                                                       | Upstream reference                                                                                                                 |
| ---------------------- | ---------------------- | ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Automation engine      | Ansible                | Requires core >=2.17.0; observed Ansible 14.3.0 / core 2.21.3 | [docs.ansible.com/ansible/latest](https://docs.ansible.com/projects/ansible/latest/index.html)                                     |
| Porting & deprecations | Ansible Porting Guide  | Match installed core release                                  | [porting guides](https://docs.ansible.com/projects/ansible/latest/porting_guides/porting_guides.html)                              |
| Release lifecycle      | Releases & maintenance | —                                                             | [release_and_maintenance.html](https://docs.ansible.com/projects/ansible/latest/reference_appendices/release_and_maintenance.html) |
| Linter                 | ansible-lint           | Unpinned requirement; observed 26.8.0                         | [ansible.readthedocs.io/projects/lint](https://ansible.readthedocs.io/projects/lint)                                               |
| YAML linter            | yamllint               | Not declared in `requirements.txt`; observed 1.38.0           | [yamllint.readthedocs.io](https://yamllint.readthedocs.io/)                                                                        |
| Runtime                | Python                 | Observed 3.14.7                                               | [python.org](https://www.python.org/)                                                                                              |
| Python dependencies    | jmespath, requests     | Unpinned in `requirements.txt`                                | —                                                                                                                                  |

### Collections

| Collection                               | Version                                                                      | Purpose                        | Upstream                                                                                                             |
| ---------------------------------------- | ---------------------------------------------------------------------------- | ------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| `community.general`                      | Used by `roles/pve_vm_clone`; not declared in `collections/requirements.yml` | Proxmox modules                | [community.general index](https://docs.ansible.com/projects/ansible/latest/collections/community/general/index.html) |
| `community.docker` / `containers.podman` | Not declared or used by repository YAML                                      | No current repository use      | [community.docker](https://docs.ansible.com/projects/ansible/latest/collections/community/docker/index.html)         |
| `community.proxmox`                      | Commented out in `collections/requirements.yml`; not used                    | No current repository use      | —                                                                                                                    |

### Target runtime infrastructure

- **Primary runner**: Ansible Semaphore UI ([ansible-semaphore.com](https://www.ansible-semaphore.com)) — visual + REST API for playbooks.
- **Delivery asset**: rootless container image built from the repo `Dockerfile` (ready-to-deploy).
- **Distribution status**: Galaxy metadata exists, but contains template values; collection packaging is deferred in `defer-galaxy-skeleton-packaging`.
- **Execution targets** (multi-target by design):
  - Bare-metal / VPS Linux (Rocky / Alma / Debian family) — `roles/os_prepare`, `roles/os_vps`, `roles/os_mount`.
  - K3s clusters — `roles/os_k3s`, `roles/k3s_gitlab_runner`.
  - Windows hosts — `roles/win_prepare`, `roles/win_container`, `roles/win_gitlab_runner`.
  - Proxmox VE — `roles/pve_vm_clone` (collection currently disabled).
  - GitLab self-hosted — `roles/con_gitlab`.

### CI/CD

- **Pipeline host**: GitLab CI includes an external Docker template and sets `RUN_ANSIBLE_LINT=true`; jobs supplied by that template are not verifiable from this repository.
- **Local quality entry point**: `scripts/quality.sh` runs configured formatting, lint, syntax, and advisory checks while retaining logs in `.validation-logs/`.
- **Configured checks**: `ansible-lint` production profile; `yamllint` default profile with line length disabled; syntax check for each `playbooks/*.yml` file.
- **Container build**: Dockerfile creates and switches to the non-root `ansible` user.

### Versioning & changelog policy

- **Versioning**: semantic versioning (MAJOR.MINOR.PATCH), npm-compatible.
- **Changelog**: [keep-a-changelog](https://keepachangelog.com/) format.
- Each role MAY be versioned independently inside the future Galaxy collection namespace.
- **This file** follows semantic versioning. Bump MAJOR for a changed binding contract, MINOR for a verified fact-set expansion, and PATCH for a correction or link fix.

---

## Structural Patterns & Skeletons

### DOX (AGENTS.md hierarchy) — binding

- The root [AGENTS.md](./AGENTS.md) is the DOX rail and is **binding** for all edits.
- Every folder that is a durable boundary owns an `AGENTS.md` with sections:
  `Purpose` → `Ownership` → `Local Contracts` → `Work Guidance` → `Verification` → `Child DOX Index`.
- Walk the DOX chain before editing; update the nearest owning doc and any affected parents/children.
- A DOX pass is mandatory after every meaningful change.
- Tool specifics belong in this file; never duplicate them into root or framework files.

### Role skeleton (mandatory)

Every role under `roles/<name>/` MUST contain:

```text
roles/<role_name>/
├── AGENTS.md           # role-level DOX contract
├── README.md           # Galaxy-style role documentation
├── defaults/           # tunable defaults (lowest precedence)
├── meta/               # meta/main.yml (dependencies, galaxy_info, info)
├── tasks/              # main.yml + optional split files
├── templates/          # Jinja2 templates (optional, role-local)
├── vars/               # role-internal vars (optional)
├── files/              # static files (optional)
└── handlers/           # handlers/main.yml (only when handlers exist)
```

Forbidden role folders: `library/`, `module_utils/`, `lookup_plugins/` (these belong in a collection, not a role).

### Playbook conventions

- One playbook per top-level intent at the repo root (`playbooks/`).
- Playbooks MUST set `collections_path = ./collections` (already enforced in `ansible.cfg`).
- Use FQCN for every module call (e.g., `ansible.builtin.copy`, `community.general.parted`).
- `gather_facts: smart` is the default; override per play only when justified.
- Idempotency is mandatory — no `command`/`shell` where a dedicated module exists.

### Galaxy collection skeleton (forward target)

When packaging, the collection layout MUST follow:

```text
collections/ansible_collections/<namespace>/<name>/
├── galaxy.yml
├── meta/runtime.yml
├── README.md
├── docs/
├── plugins/
│   ├── modules/
│   ├── inventory/
│   └── ...
├── roles/
│   ├── <role_a>/
│   └── <role_b>/
├── playbooks/
└── tests/
```

Build & publish flow (reference: [developing_collections_creating.html](https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_collections_creating.html)):

```bash
ansible-galaxy collection build   # produces .tar.gz
ansible-galaxy collection publish <tarball>   # to Galaxy
```

`galaxy.yml` MUST declare `namespace`, `name`, `version`, `readme`, `authors`, `license`, `tags`, and `repository`.

### README standard (Galaxy-style)

Each `roles/<role>/README.md` MUST cover, in order:

1. Role name and short description.
2. Requirements (Ansible version, collections, OS family).
3. Role variables (defaults table grouped by `default/`, `vars/`).
4. Dependencies (`meta/main.yml` mirror).
5. Example playbook.
6. License / author.

### Quality enforcement

- **ansible-lint** uses the configured `production` profile. Do not suppress findings without a documented, scoped justification.
- **yamllint** uses its default profile with line length disabled.
- **Syntax check** covers every `playbooks/*.yml` file through `scripts/quality.sh`.
- **Collection sanity tests** become required when collection packaging is approved and implemented.

---

## Local Constraints & Anti-Patterns

### Hard bans

- **No invented features.** Implement only what the user explicitly authorizes. No new roles, abstractions, or product surface without direct ask. (Root `AGENTS.md` user preference.)
- **No deprecated modules.** Examples banned outright:
  - `docker_container` (use `community.docker.docker_container` or `containers.podman.podman_container`).
  - `community.general.yaml` as a stdout callback (use `community.general.default` / `yaml` core callback only).
  - `command`/`shell` where a dedicated, idempotent module exists.
  - Any module flagged in the [community.general changelog](https://docs.ansible.com/projects/ansible/latest/collections/community/general/changelog.html) as `DEPRECATED`.
- **No rule duplication across roles.** DOX rule: do not repeat the same rule in many files unless each scope truly needs its local copy.
- **No stale documentation.** Remove contradictory or outdated text instead of explaining history.
- **No world-readable temporary files**: do not enable `allow_world_readable_tmpfiles`.
- **No committed `.retry` files** (`retry_files_enabled = False` in `ansible.cfg`).

### Anti-patterns to actively reject in review

- Hardcoded credentials, tokens, or hostnames in any role/playbook — use `ansible-vault` or `vars_prompt`.
- Missing `meta/main.yml` `galaxy_info` block on a role intended for distribution.
- Skipping the DOX pass after a behavior-changing edit.
- Adding `library/` or `module_utils/` inside a role (move to a collection).
- Using `with_items` instead of the unified `loop` keyword.
- Using `ignore_errors: yes` without a comment explaining why.
- Setting `state: latest` for packages without justification (ansible-lint `package-latest` rule).
- Re-declaring variables in multiple places at the same precedence.
- Treating `collections/requirements.yml` as optional — any new collection MUST be added there with a version floor.

### Modernization discipline

- When an upstream module is deprecated or replaced, the role that depends on it MUST be updated in the same change set that introduces the replacement.
- New roles MUST use current Ansible idioms (FQCN, `loop`, `block`/`rescue`, `ansible.builtin.*` for core modules).
- Container assets MUST run rootless; do not regress to rootful Docker.

---

## Maintenance

- **Source of truth**: this file. Overrides any README claim.
- **Update triggers**:
  - Locked tool version bump (Ansible, ansible-lint, yamllint, collections).
  - New role added or role skeleton changed.
  - Anti-pattern discovered or banned.
  - CI gate changed or added.
- **Verification cadence**: run `/techstack audit` (see `.github/prompts/techstack.prompt.md`) on every trigger; HEAD-check upstream URLs quarterly.
- **Versioning rule for this file**: MAJOR on locked tool change or skeleton rewrite; MINOR on a new section or collection pin; PATCH on typo/link fix.
- **Owner**: root `AGENTS.md` owner. Per-role specifics live in each role's `AGENTS.md`, not here.

---

## Locked upstream API map

| Concern                  | Reference                                                                                           |
| ------------------------ | --------------------------------------------------------------------------------------------------- |
| Ansible core docs        | https://docs.ansible.com/projects/ansible/latest/index.html                                         |
| Ansible porting guides   | https://docs.ansible.com/projects/ansible/latest/porting_guides/porting_guides.html                 |
| Releases & maintenance   | https://docs.ansible.com/projects/ansible/latest/reference_appendices/release_and_maintenance.html  |
| ansible-galaxy CLI       | https://docs.ansible.com/projects/ansible/latest/cli/ansible-galaxy.html                            |
| Collection creation      | https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_collections_creating.html     |
| Collection structure     | https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_collections_structure.html    |
| Distributing collections | https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_collections_distributing.html |
| ansible-lint             | https://ansible.readthedocs.io/projects/lint                                                        |
| ansible-lint rules       | https://ansible.readthedocs.io/projects/lint/rules/latest                                           |
| community.general        | https://docs.ansible.com/projects/ansible/latest/collections/community/general/index.html           |
| Semaphore UI             | https://www.ansible-semaphore.com                                                                   |
| keep-a-changelog         | https://keepachangelog.com/                                                                         |

---

## Changelog

All notable changes to this file are documented here. Format follows [keep-a-changelog](https://keepachangelog.com/).

### v1.1.0 — 2026-08-13

**Changed**

- Rebuilt runtime, dependency, collection, CI, quality, and packaging claims from repository configuration and installed-tool evidence.
- Removed unsupported Ansible 10, pinned-dependency, CI, collection, lint-profile, and YAML-style claims.

### v1.0.0 — 2026-06-21

**Added**

- Version tag (`v1.0.0`) and Semver versioning policy for this file.
- `## Maintenance` section: source-of-truth, update triggers, verification cadence, owner.
- Cross-links to root `AGENTS.md`, the maintenance prompt, and the template source.
- `## Changelog` section.

**Changed**

- Replaced emoji headers (`🛠️🔍📐🚫🔗`) with plain text to keep file Caveman-neutral.
- Locked date moved into a `Version` line that combines `v1.0.0` and `2026-06-21`.
- Each table cell now states one fact (no bold style on locked values inside cells).
