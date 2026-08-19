# Skeleton TLDR — handoff for next session

> Quick-reference for the role skeleton work done in this session. Read this in a fresh session to resume.

## Goal

Finalize `roles/.skeletons/role_skeleton/` — pre-configured Podman Quadlet skeleton consumed by `ansible-galaxy role init`. Generates roles that deploy nginx hello-world out of the box.

## What was done

- Built complete skeleton (15 files).
- Iterated on conventions: all underscores, no 1:1 passthroughs, JSON-in-YAML only for `[]`, noqa only where necessary.
- Renamed folder `role-skeleton` → `role_skeleton` (per user: no dashes).
- Updated `ansible.cfg:325` to point to renamed path.
- Set up `.ansible-lint` with skip_list and exclude_paths.
- Verified end-to-end: render, lint, syntax-check.

## Final structure

```
roles/.skeletons/role_skeleton/
├── AGENTS.md                          AI guide (updated to match current state)
├── README.md                          user guide
├── defaults/main/
│   ├── 00-general.yml                 shared vars: storage_base_path, http, app_path, app_user, app_group, container_network_create
│   └── 10-install.yml.j2              role vars: _image, _version, _container_network_create, _user_mode, _ports, _dirs
├── files/.gitkeep
├── handlers/main.yml                  single Restart handler (no .j2)
├── meta/main.yml.j2                   galaxy_info
├── tasks/
│   ├── 00-prepare.yml                 banner + create-user (rootless) + data dir + dirs loop
│   ├── 10-install.yml                 render + symlink + URI healthcheck
│   ├── 20-config.yml                  banner
│   └── main.yml                       preflight + OS vars + glob
├── templates/
│   ├── quadlet_app.container.j2       hardcoded hello-world nginx
│   ├── quadlet_default.network.j2     name derived inline
│   └── quadlet_default.env.j2         example DATABASE_URL
└── vars/main.yml                      app_name, app_user, app_group, app_path derivations
```

## Conventions (enforced)

- **All underscores** in filenames, folder names, var names. No dashes.
- **No 1:1 passthroughs** — `{{ role_name }}_app_path: "{{ app_path }}"` is rejected.
- **JSON in YAML** only for `[]` (empty). Populated lists use `- "value"` block form.
- **Var categories**:
  - `defaults/main/00-general.yml`: shared, unprefixed, `noqa var-naming[no-role-prefix]`.
  - `defaults/main/10-install.yml.j2`: role-prefixed, `noqa var-naming`.
  - `vars/main.yml`: derived, unprefixed, `noqa var-naming[no-role-prefix]`.
- **`app_user`** = `app_name | replace('_', '-')` (shell-safe).
- **`app_group`** = `"data"` (fixed; shared data group on host).
- **`app_path`** = `<storage_base_path>/<app_name>`.

## Known constraints (design decisions)

- **`ansible-galaxy role init` only binds `{{ role_name }}` at init time.** Cross-file refs in `.j2` files fail. So:
  - Templates use only `{{ role_name }}` + inline derivations + literal paths (`/data/...`).
  - Defaults/handlers/tasks use `{{ {{ role_name }}_xyz }}` (Ansible recursive templating) for role-prefixed vars — Ansible resolves at runtime.
- **Jinja in filenames is NOT templated by `ansible-galaxy role init`.** Test template `{{ role_name }}_test.container.j2` copied verbatim. Template filenames must be static.
- **Network name**: derived inline as `<app_name>_default`. No `_container_network_name` var.
- **Healthcheck URL**: derived inline in `tasks/10-install.yml` from `{{ {{ role_name }}_ports | first | split(':') | first }}` (host-side port). No `_healthcheck_url` var.
- **No `lookup('vars', ...)`** in the same role — use `{{ {{ role_name }}_xyz }}` instead.
- **Templates hardcode hello-world** (nginx on port 8080). Per-role: edit template for Image/Ports/Exec.

## `.ansible-lint` config (project root)

```yaml
skip_list:
  - name[template]
  - jinja[invalid] # nested {{ {{ role_name }}_xyz }} is valid Ansible recursive templating
  - no-jinja-when # role-prefixed var lookups in when clauses
exclude_paths:
  - "**/templates/" # systemd unit files, not YAML
```

## `.ansible-lint` outputs

- `ansible-lint roles/.skeletons/role_skeleton/` → 0/0 on 13 files, production.
- `ansible-lint <generated_role>/` → 0/0 on 1 file, production.

## `ansible.cfg:325-326`

```ini
role_skeleton = ./.skeletons/role_skeleton
role_skeleton_ignore = ^.git$,^.*/.gitkeep$,^\./AGENTS\.md$
```

## Verification commands

```bash
# Render
ansible-galaxy role init test_skel \
  --role-skeleton=./roles/.skeletons/role_skeleton \
  --init-path=/tmp/test_skel_out --offline --force

# Lint skeleton + generated
ansible-lint roles/.skeletons/role_skeleton/
ansible-lint /tmp/test_skel_out/test_skel/

# Syntax-check
ANSIBLE_ROLES_PATH=/tmp/test_skel_out \
  ansible-playbook -i localhost, -c local <playbook>.yml --syntax-check
```

## Known future work (not done in this session)

- Live roles (`con_*`, `os_*`, `win_*`, `k3s_*`, `pve_*`) still diverge from skeleton. Converge one at a time on next touch.
- Optional `{{ role_name }}_app_name_override` var — user wanted this but it conflicts with galaxy-init template constraint. Skipped.
- Skeleton README.md may still reference older patterns; verify on next pass.
- Root AGENTS.md and TECHSTACK.md untouched (intentional, per DOX).

## Do not change (locked)

- `roles/.skeletons/role_skeleton/AGENTS.md` — AI contract, current.
- `.ansible-lint` — skip_list + exclude_paths tuned.
- `ansible.cfg:325-326` — role_skeleton path.
- `vars/main.yml` derivations: `app_name`, `app_user`, `app_group: "data"`, `app_path`.

---

## Session 2 outcome (2026-06-27)

### What changed

- **README.md** rewritten to be user-facing only. Dropped nonexistent `_healthcheck_url` and `_container_network_name` defaults; dropped false "no .j2 on templates" and "no noqa" rules.
- **Skeleton AGENTS.md** slimmed to skeleton-specific contracts. Dropped "Starting guide" (README owns user-facing how-to).
- **`.ansible-lint`** trimmed: removed `jinja[invalid]`, `no-jinja-when`, `exclude_paths`. No global disables — `name[template]` only.
- **vars/main.yml** `app_group` derivation: `data` (rootful) or `app_user` (rootless). Resolves once at load time, no `set_fact`.
- **`tasks/00-prepare.yml`** rewritten with explicit two-path (rootful/rootless) per case. No inline ternary lookups.
- **`tasks/10-install.yml`** reordered: network Quadlet first. Block name "Template Quadlets".
- **Templates** dropped `.j2` extension (plain files, Ansible renders at runtime). Use `lookup('vars', role_name + '_foo')` for dynamic role-prefixed var access; `{{ {{ role_name }}_foo }}` doesn't work in Jinja parser.
- **DOX**: `roles/AGENTS.md` and root `AGENTS.md` Child DOX Index both reference `.skeletons/role_skeleton/**`.

### What didn't change

- Live role convergence (`con_*`, `os_*`, `win_*`) — still on next touch.
- TECHSTACK.md — untouched (skeleton already conforms to its role-layout contract).

### Verification

- `ansible-galaxy role init` against skeleton: success.
- `ansible-lint roles/.skeletons/role_skeleton/`: 0/0 on 16 files, production profile.
- `ansible-lint .skel-out/test_skel/`: 0/0 on 14 files, production profile.
- Quadlet render output: scalar, list (volumes/ports), dict (env_vars), OR-fallback (container_name), extra_args all confirmed via render_test playbook.
