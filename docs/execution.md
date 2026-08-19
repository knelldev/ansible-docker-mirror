# Execution Guide

Use the same playbooks and external inventory in three ways:

- **Local Ansible** for development and small controlled runs.
- **The container image** for a reproducible Ansible controller.
- **Semaphore UI** for shared operations, approvals, schedules, and run history.

The recommended operational setup is Semaphore. Local Ansible is the simplest
way to develop and test changes. The container image is useful when the
controller environment must be consistent.

## Before You Start

Prepare these inputs outside the repository:

- An inventory with the target hosts and connection settings.
- Credentials in Ansible Vault, Semaphore secrets, or another secret manager.
- The required collections from `collections/requirements.yml`.
- A selected playbook and, where appropriate, a one-host `--limit`.

Never commit inventories, private keys, API tokens, passwords, or rendered
secret files.

## Local Ansible

Install the controller dependencies:

```bash
python -m pip install -r requirements.txt
ansible-galaxy collection install -r collections/requirements.yml
```

Check and run a playbook:

```bash
ansible-playbook --syntax-check playbooks/ping_local.yml
ansible-playbook -i inventory/hosts.yml playbooks/os_prepare.yml \
  --limit container_hosts
```

Run `scripts/quality.sh` before sharing a change. Start target changes with a
single host, review the result, and expand the limit deliberately.

## Container Image

Build the controller image and mount inventory and keys read-only:

```bash
docker build -t ansible-docker:dev .
docker run --rm \
  -v "$(pwd)/inventory:/ansible/inventory:ro" \
  -v "$HOME/.ssh/id_ed25519:/ansible/.ssh/id_ed25519:ro" \
  ansible-docker:dev \
  ansible-playbook -i /ansible/inventory/hosts.yml \
  /ansible/playbooks/os_prepare.yml --limit container_hosts
```

Keep vault passwords and other secrets outside the image. The controller image
is non-root; Linux target roles still require the target's Podman and systemd
prerequisites.

## Semaphore UI

Use one Semaphore project connected to the repository and create a task
template for each operational playbook or safe workflow.

Configure:

1. The repository and the intended branch or tag.
2. An external inventory or inventory repository.
3. SSH keys and API credentials as Semaphore secrets.
4. An environment for non-secret variables such as `hosts_limit`.
5. A task template with the playbook, inventory, and required limit.

Example template values:

```text
Playbook: playbooks/os_prepare.yml
Inventory: /path/to/inventory
Extra variables: hosts_limit=container_hosts
```

Run the template manually first. Add schedules or approval rules after the
manual run is understood. Keep the Semaphore project, template, revision,
inventory reference, and run output linked to the operational ticket.

## Typical Workflow

1. Review the role README and selected playbook.
2. Run repository quality checks and a syntax check.
3. Run against one target with an explicit limit.
4. Check idempotence by running the same task again.
5. Review service state and target-side changes.
6. Expand the target limit or schedule the approved Semaphore run.

## Troubleshooting

- **Inventory not found:** check the `-i` path or Semaphore inventory configuration.
- **Permission denied:** verify SSH key mounts, credentials, and target privilege settings.
- **Missing module or collection:** install `collections/requirements.yml`.
- **Unexpected changes:** rerun with one host and inspect variables before widening the limit.

For role-specific variables and requirements, use the README in the selected
role directory.
