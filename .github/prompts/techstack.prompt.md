---
name: techstack
description: Discover, verify, or audit the repository's TECHSTACK.md file. Detects mode automatically.
argument-hint: "[seed|audit|refresh] — default: auto-detect"
---

# Techstack Prompt

Maintain the project's `TECHSTACK.md` binding reference. Three modes, auto-detected from argument and current state.

## Mode Detection

1. If `$ARGUMENTS` is `seed` → force seed mode (overwrite).
2. If `$ARGUMENTS` is `audit` → force audit mode (diff + verification only).
3. If `$ARGUMENTS` is `refresh` → force refresh mode (re-verify upstream links only).
4. Otherwise auto-detect:
   - `TECHSTACK.md` absent → seed mode.
   - `TECHSTACK.md` present + user asks to verify → audit mode.
   - `TECHSTACK.md` present + no specific ask → audit mode (safer default).

State the chosen mode in the first reply line. No greetings.

## Mode A — Seed

Generate `TECHSTACK.md` from scratch via interactive discovery. Use dialogue freely; ask follow-ups when answers are ambiguous. Do not assume defaults silently.

### Step 1 — Discovery Dialogue

Output the header `### Techstack Blueprint Discovery`. Ask these in order, one cluster per turn to keep responses scannable:

1. **Stack & versions.** Core languages, runtimes, compilers. Ask the user to paste `tool --version` outputs when relevant.
2. **Runtime targets.** Containers, VMs, bare-metal, hypervisors, OS families.
3. **Quality gates.** Required linters, formatters, CI checks.
4. **Architecture patterns.** Directory layout, module boundaries, naming conventions that MUST be followed.
5. **Anti-patterns.** Banned practices, legacy modules, forbidden abstractions.

For each cluster, accept partial answers and ask targeted follow-ups only on ambiguities. Maximum 5 follow-up rounds total before drafting.

### Step 2 — Upstream Verification

Run web searches for the official docs of every locked tool/version. Present links under `### Upstream API Mapping`. Ask the user to confirm or replace any link.

### Step 3 — Write File

Write `TECHSTACK.md` at repo root using the structural template below. Never invent tools not confirmed by the user.

## Mode B — Audit

Verify the existing `TECHSTACK.md` against the actual repo state and current upstream docs. No new file unless the audit finds gaps.

### Step 1 — Read

Read `TECHSTACK.md` fully. Read `AGENTS.md` and one role's `AGENTS.md` to cross-check role skeleton claims.

### Step 2 — Drift Detection

Compare claims to ground truth:

| Check                  | Source                                                                 |
| ---------------------- | ---------------------------------------------------------------------- |
| Tool versions          | `requirements.txt`, `requirements.yml`, `collections/requirements.yml` |
| Linters wired in CI    | `.gitlab-ci.yml` / `.github/workflows/`                                |
| Role skeleton matches  | one role's directory tree                                              |
| Anti-patterns violated | grep for banned modules/patterns                                       |
| DOX contract present   | every role folder has `AGENTS.md`                                      |

### Step 3 — Report

Output under `### TECHSTACK.md Audit Report`:

- **Verified**: claims confirmed by current state.
- **Drift**: claims that no longer match. List with file:line evidence.
- **Missing**: topics `TECHSTACK.md` should cover but doesn't.
- **Recommended edits**: concrete diffs the user can apply.

Ask before writing any changes. Audit is read-only by default.

## Mode C — Refresh

Re-verify upstream doc links in `TECHSTACK.md`. No structural changes.

### Step

1. Extract every URL from `TECHSTACK.md`.
2. HTTP HEAD each link (or web search if HEAD unavailable).
3. Report: live / broken / redirected. For broken/redirected links, propose replacements from official sources.

## Structural Template

Template lives at `.github/prompts/techstack.template.md` (sibling file). Read it, copy the fenced block, fill placeholders, write to repo root as `TECHSTACK.md`. Keeps the prompt lean and the template reviewable in isolation.

## Constraints

- Never abbreviate tool names (API, config, function, request, response stay literal).
- Locked dates use ISO format `YYYY-MM-DD`.
- Prefer tables for stack data; bullets only for narrative rules.
- Cap output: seed ≤ 80 lines, audit report ≤ 60 lines, refresh report ≤ 40 lines.
- If `TECHSTACK.md` write fails, surface the error and offer the content as a fenced block for manual paste.
