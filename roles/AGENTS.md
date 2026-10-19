# DOX framework - roles/

## Purpose

This directory contains Ansible roles for infrastructure automation. All roles follow a unified structure regardless of target platform.

> **Note:** Roles use `include_tasks` (runtime discovery), not `import_tasks`. This breaks static analysis like tags and system checks.

## Ownership

- Primary: Platform Engineering Team
- Secondary: DevOps Engineers
- Maintenance: All contributors following DOX guidelines

## Local Contracts

### Directory Structure (Ansible Standard)

Implemented roles follow standard Ansible layout with top-level `tasks/`,
`defaults/main/`, `vars/`, `templates/`, and `meta/` directories. Some roles
include a `files/` directory when static assets are needed. `os_mount`
currently has planning/contract files only and is not an implemented role
skeleton. `os_wg` is a generated skeleton with a draft variable contract and
TODO task files.

### tasks/main.yml Pattern (Maintenance-Free)

Every role `tasks/main.yml` implements the same standardized entry point:

1. **Pre-flight validation** — Scans for `__REQUIRED__` sentinel values in role-prefixed variables, fails with descriptive list of missing vars
2. **OS-specific var loading** — Uses `with_first_found` cascade to load OS + version specific vars from `vars/`
3. **Task inclusion loop** — Runtime dynamic file discovery using `include_tasks` with glob pattern `[0-9][0-9]-*.yml`

> **Note:** Non-numbered utility files (e.g., `register.yml`) are available for on-demand conditional inclusion but not executed during standard play runs.

### File Organization

#### defaults/main/

- Always include `00-general.yml` with shared variables (no role prefix for simplicity)
- App-specific defaults: `10-appname.yml`, `11-appname-smtp.yml`, etc.
- Variable naming follows ansible-lint convention (role-prefixed)

#### vars/

- Use a single `vars/main.yml` entry point for role-internal variables.
- Every `vars/main.yml` starts with the same six lines, each marked
  `# noqa var-naming[no-role-prefix]`: `app_name` (role name without its
  prefix), `app_path` (`storage_base_path/app_name`), `app_user` (`app_name`
  with hyphens), `app_group` (`app_user`), `app_user_create` (`false`) and
  `app_dir_extra` (`[]`). Each one is overridable as `<role>_name`,
  `<role>_path`, `<role>_user`, `<role>_group`, `<role>_user_create` and
  `<role>_dir_extra`; set the role's own `<role>_dir_extra` in defaults.
- Preserve any additional role-internal variables in the same file.
- OS-specific resolution cascade using `with_first_found`

#### tasks/

- Two-digit numbered files (`00-prepare.yml`, `10-install.yml`, `20-config.yml`) automatically discovered
- `00-prepare.yml` is shared and identical in every role that stores files
  on the host (copy it from the skeleton, never edit it per role). It creates
  a system user and group without home when `app_user_create`, then one
  directory task for `app_path` plus `app_dir_extra`. `app_path` and
  `<role>_dir_extra` items default to owner `root` (`app_user` with
  `app_user_create`), group `storage_group` (`app_group` with
  `app_user_create`), mode `0700`, recurse `false`. To isolate a role from the
  shared group, add a `name: ""` item with its own group/mode in
  `<role>_dir_extra`; it runs after the default root entry. Role-specific
  checks and prerequisites go into a later file such as `05-validate.yml`.
  Roles that store nothing have no `00-prepare.yml`: `os_container`,
  `os_gitlab_runner`, `os_template_reset`, `os_wg`, `pve_*`, `win_*`;
  `os_prepare` creates `storage_base_path` itself and `os_k3s` leaves its
  directory to the k3s installer.
- The last task of `tasks/main.yml` writes a local fact,
  `/etc/ansible/facts.d/<role>.fact` (JSON: role, repo commit, timestamp,
  Ansible version, `info` from the optional `templates/fact-info.json.j2`, and
  the values of the previous run). `<role>_fact_enabled: false` skips it
  (Windows and Proxmox API roles).
- File extensions: `.yml` for Ansible files, `.yaml` for Kubernetes manifests (incl. `.j2` templates).
- Templates start with `# {{ ansible_managed }}` where the format allows
  comments (after the shebang in scripts; not in JSON). Roles with several systemd units render them from one
  `templates/systemd-unit.j2` fed by a map in `vars/main.yml`.
- Recommended spacing: gap between numbers allows insertion without renumbering

### Task File Naming Convention

All roles follow the same pattern regardless of prefix:

| Prefix             | Target                                 |
| ------------------ | -------------------------------------- |
| `con_*`            | Container deployments (Podman/Quadlet) |
| `os_*`             | OS-level configuration                 |
| `win_*`            | Windows targets                        |
| `k8s_*` / `kube_*` | Kubernetes components                  |
| `pve_*`            | Proxmox infrastructure                 |

### Variable Naming

All mandatory variables use role-prefixed naming (`<role_name>_*`). Only a few general shared variables exist at playbook inventory level.

## Work Guidance

### Creating a New Role

1. Copy structure from an existing similar role
2. Ensure `00-general.yml` in defaults, `main.yml` in vars, and the shared `00-prepare.yml` in tasks when the role stores files
3. Follow standard task sequence: `00-prepare` → `10-install` → `20-config`

### Task File Naming

Use two-digit numbers: `00-prepare.yml`, `10-install.yml`, `20-config.yml`

Sequential ordering ensures execution order matches numbering. Gap between numbers (10, 20, 30) allows insertion of new task files without renumbering.

## Verification

- All roles pass ansible-lint and yamllint checks
- Variable validation tests included in CI pipeline
- OS-specific vars tested across supported platforms

## Child DOX Index

Individual role [`AGENTS.md`](AGENTS.md) files exist for all roles:

- **con_caddy/** - Per-host Caddy reverse proxy
- **con_gitlab/** - GitLab container deployment
- **con_minio/** - MinIO object storage
- **con_nginx/** - Nginx reverse proxy (deprecated, use con_caddy)
- **con_semaphore/** - Semaphore CI/CD
- **k3s_gitlab_agent/** - GitLab agent for Kubernetes (agentk) on K3s
- **k3s_gitlab_runner/** - GitLab Runner on K3s
- **os_container/** - OS container runtime setup
- **os_gitlab_runner/** - GitLab Runner installation
- **os_k3s/** - K3s Kubernetes cluster
- **os_mount/** - NFS server/client
- **os_prepare/** - OS preparation
- **os_template_reset/** - Reset a guest before templating
- **os_wg/** - WireGuard endpoint (draft) with an optional edge part for an entry VPS
- **pve_ct_template/** - Proxmox LXC template build
- **pve_vm_clone/** - Proxmox VM cloning
- **win_container/** - Windows container setup
- **win_gitlab_runner/** - GitLab Runner on Windows
- **win_prepare/** - Windows OS preparation
- **.skeletons/role_skeleton/** - Role skeleton consumed by `ansible-galaxy role init` for new roles
