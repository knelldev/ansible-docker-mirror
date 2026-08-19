# Ansible Docker

Rootless Ansible automation for Linux, Windows, K3s, GitLab Runner, and
Proxmox environments. The repository is delivered as a non-root container
image and is also usable from a local Ansible installation.

## Documentation

This root README is the general project guide.

- [Execution guide](docs/execution.md): local, container, and Semaphore setup
- [Execution model](docs/execution.md): choose local, container, or Semaphore execution
- [Role documentation](roles/)
- [Verified technology and quality contracts](TECHSTACK.md)
- [OpenSpec behavior and implementation plans](openspec/)
- [Architecture decisions](docs/decisions/)

Role-level `README.md` files remain next to roles because they document each
role's variables, requirements, dependencies, and example invocation. They are
not additional general project guides.

## What This Repository Provides

- Linux preparation and Podman-based application roles
- K3s cluster and GitLab Runner automation
- Windows preparation and GitLab Runner automation
- Proxmox VM cloning
- A rootless Ansible controller image

## Repository Layout

```text
ansible-docker/
├── playbooks/              # Top-level Ansible playbooks
├── roles/                  # Reusable Ansible roles
├── roles/.skeletons/       # Role skeleton for ansible-galaxy init
├── collections/            # Collection dependency declarations
├── Dockerfile              # Rootless Ansible image
└── requirements.txt        # Python dependencies
```

## Prerequisites

- Ansible Core 2.17 or newer
- Python dependencies from `requirements.txt`
- Collections from `collections/requirements.yml` when required
- Podman on Linux targets for `os_*` and `con_*` roles
- Docker on Windows targets for `win_container`

## Quick Start

Build the image:

```bash
docker build -t ansible-docker:latest .
```

Run a playbook with an explicit inventory:

```bash
docker run --rm \
  -v "$(pwd)/inventory:/ansible/inventory" \
  ansible-docker:latest \
  ansible-playbook -i /ansible/inventory/hosts /ansible/playbooks/os_prepare.yml
```

The image runs as the non-root `ansible` user with UID 1000. For setup choices,
inventory handling, and Semaphore configuration, see
[`docs/execution.md`](docs/execution.md).

## Available Playbooks

- `os_prepare.yml`, `os_container.yml`, and `os_k3s.yml` for Linux preparation,
  container runtime setup, and K3s
- `con_gitlab.yml`, `con_minio.yml`, `con_nginx.yml`, and `con_semaphore.yml`
  for Podman container deployments
- `k3s_gitlab_runner.yml` for GitLab Runner on K3s
- `win_container.yml`, `win_gitlab_runner.yml`, and
  `win_gitlab_runner_only.yml` for Windows targets
- `pve_vm_clone.yml` for Proxmox VM cloning
- `ping.yml` and `ping_local.yml` for connectivity and callback checks

## Development

Run the configured repository checks before committing:

```bash
scripts/quality.sh
```

The script runs formatting, Ansible lint, YAML lint, playbook syntax checks,
and available Python, Markdown, Dockerfile, and shell checks. Logs are kept in
the ignored `.validation-logs/` directory.

Use the OpenSpec CLI to inspect accepted specs and active plans:

```bash
openspec list --changes
openspec list --specs
openspec status --change <change-name> --json
```

## Distribution

Galaxy metadata exists, but collection packaging and publication are deferred.
The active delivery asset is the rootless container image built from this
repository.

## License

MIT. See [LICENSE.md](LICENSE.md).
