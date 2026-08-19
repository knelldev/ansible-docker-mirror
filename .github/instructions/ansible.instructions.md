---
applyTo: "**/*.{yml,yaml}"
description: "Ansible implementation and verification guidance."
---

# Ansible Guidance

- Apply only to Ansible-owned YAML. Do not treat all YAML as playbook content.
- Use fully qualified collection names for modules.
- Prefer idempotent modules over `command` or `shell`.
- Use `loop`, not deprecated `with_*` loops.
- Keep secrets out of repository source and use existing variable contracts.
- Run relevant `ansible-lint`, `yamllint`, and `ansible-playbook --syntax-check` checks when available.
- Dynamic `include_tasks` limits static task and tag analysis; record focused verification for risky changes.
