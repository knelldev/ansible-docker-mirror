# TECHSTACK.md Structural Template

Sourced from `.github/prompts/techstack.prompt.md` (Mode A — Seed). Copy this block, fill the placeholders, drop into repo root as `TECHSTACK.md`.

```markdown
# Project Tech Stack & Blueprint Matrix

> Binding reference for the `<workspace>` workspace. All new <artifacts> MUST conform to the contracts below. Locked at: <YYYY-MM-DD>.

---

## Core Technology Stack

### <Runtime layer name>

| Layer | Tool | Version | Upstream reference |
| ----- | ---- | ------- | ------------------ |

### Target runtime infrastructure

- <Bullet list of execution targets>

### CI/CD

- Pipeline host, quality gates, build artifacts.

### Versioning & changelog policy

- Versioning scheme, changelog format, per-artifact version rules.

---

## Structural Patterns & Skeletons

### DOX (AGENTS.md hierarchy)

- <Binding rules for the AGENTS.md chain in this repo>

### <Skeleton name> (mandatory)

<Directory tree as fenced text>

### Convention blocks

- <3–6 bullets of named conventions, each one rule>

---

## Local Constraints & Anti-Patterns

- <3–6 banned practices with rationale and grep-friendly markers>

---

## Maintenance

- **Source of truth**: this file. Overrides any README claim.
- **Update trigger**: any locked tool version bump, new role added, anti-pattern discovered, CI gate changed.
- **Verification cadence**: <quarterly | on major bump | manual>.
- **Owner**: <role or person who can amend this file>.
```

## Placeholder cheat sheet

| Placeholder            | Replace with                                                              |
| ---------------------- | ------------------------------------------------------------------------- |
| `<workspace>`          | repo name (`ansible-docker`)                                              |
| `<artifacts>`          | what this repo produces (roles, playbooks, collections, container images) |
| `<YYYY-MM-DD>`         | today's date, ISO format                                                  |
| `<Runtime layer name>` | e.g. "Automation runtime", "Build pipeline"                               |
| `<Skeleton name>`      | e.g. "Role skeleton", "Playbook skeleton"                                 |
| `<role or person>`     | owning entity from `AGENTS.md`                                            |

## Drift markers (grep-friendly)

When the audit finds violations, search the repo with these patterns:

- Banned role folders: `library/`, `module_utils/`, `lookup_plugins/` inside `roles/`
- Non-FQCN module calls: regex `\b(copy|file|template|service|systemd|user|package|apt|yum|dnf|command|shell)\s*:` not preceded by collection namespace
- Inline shell: `^\s*-\s*(command|shell|raw):`
- Missing role AGENTS.md: find `roles/* -maxdepth 1 -type d ! -name AGENTS.md -exec test ! -f {}/AGENTS.md \;`
