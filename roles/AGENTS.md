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
include a `files/` directory when static assets are needed. `os_mount` and
`os_vps` currently have planning/contract files only and are not implemented
role skeletons.

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
- Application roles define derived `app_name`, `app_path`, and `app_user` values
  there when those variables apply.
- Preserve any additional role-internal variables in the same file.
- OS-specific resolution cascade using `with_first_found`

#### tasks/

- Two-digit numbered files (`00-prepare.yml`, `10-install.yml`, `20-config.yml`) automatically discovered
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
2. Ensure `00-general.yml` in defaults, `00-prepare.yml` in tasks, and `main.yml` in vars
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

- **con_gitlab/** - GitLab container deployment
- **con_minio/** - MinIO object storage
- **con_nginx/** - Nginx reverse proxy
- **con_semaphore/** - Semaphore CI/CD
- **con_watchtower/** - Watchtower auto-update
- **k3s_gitlab_runner/** - GitLab Runner on K3s
- **os_container/** - OS container runtime setup
- **os_gitlab_runner/** - GitLab Runner installation
- **os_k3s/** - K3s Kubernetes cluster
- **os_mount/** - NFS server/client
- **os_prepare/** - OS preparation
- **os_vps/** - VPS optimizations
- **pve_vm_clone/** - Proxmox VM cloning
- **win_container/** - Windows container setup
- **win_gitlab_runner/** - GitLab Runner on Windows
- **win_prepare/** - Windows OS preparation
- **.skeletons/role_skeleton/** - Role skeleton consumed by `ansible-galaxy role init` for new roles
