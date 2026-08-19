## Context

The current Dockerfile sets `ANSIBLE_HOME=/ansible`, copies repository content
owned by `ansible`, and switches to UID 1000. The contract must align with
`TECHSTACK.md` and the container setup in `docs/execution.md`.

## Decisions Required

- Whether UID/GID 1000 is stable compatibility or only a current default.
- Which paths are writable at runtime.
- How SSH keys, inventories, vault files, and callback logs are mounted.
- Whether image builds must install collections or only Python dependencies.
- Which rootless container engines are supported for the controller.

## Verification Shape

Build checks must inspect effective user, ownership, writable paths, Ansible
configuration, and a syntax-only playbook run without credentials.
