## Status

- Approval: removal requested by the owner on 2026-10-19 (retire the role).
- Plan state: done; not archived yet.

## Tasks

- [x] Inventory Watchtower references and current role behavior: no playbook
      used the role; only `roles/AGENTS.md` listed it.
- [x] Decide supported, opt-in, or retired status: retired (owner,
      2026-10-19). Container updates stay with `podman-auto-update.timer`
      from `os_container`.
- [x] Define update, rollback, and maintenance-window contract: not needed
      after retirement.
- [x] Update documentation: role directory and the `roles/AGENTS.md` index
      entry removed.

## Verification Evidence

- 2026-10-19: `grep -ri watchtower` outside `openspec/` and `.ai/recovery/`
  finds nothing; all playbooks pass `--syntax-check`.

## Next Action

Archive the change after the owner confirms the result.
