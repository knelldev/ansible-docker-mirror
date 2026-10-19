# Ansible Role Skeleton

Generic starter for non-Windows roles in the `knelldev.rituals` collection.
It follows the repository role convention without assuming a container,
Quadlet, Kubernetes, Proxmox, or other runtime.

## Requirements

- Ansible core 2.17 or newer.
- Linux targets; EL 9 and EL 10 are the initial documented baseline.
- Add any role-specific collections in the generated role documentation.

## Create a role

```bash
ansible-galaxy role init <role_name> \
  --role-skeleton=./roles/.skeletons/role_skeleton \
  --init-path=./roles \
  --offline
```

The generated role includes:

```text
<role_name>/
├── README.md
├── defaults/main/00-general.yml
├── defaults/main/10-role.yml
├── meta/main.yml
├── tasks/
│   ├── 00-prepare.yml
│   ├── 10-install.yml
│   ├── 20-config.yml
│   └── main.yml
└── vars/main.yml
```

`tasks/main.yml` is the shared role entry point. It validates required
role-prefixed variables, loads the first matching OS-specific vars file, and
discovers numbered task files in ascending order. It ends by writing a local fact,
`/etc/ansible/facts.d/<role>.fact` (role, repo commit, time, Ansible version,
optional `templates/fact-info.json.j2`, previous run); `<role>_fact_enabled:
false` skips it. The generated `vars/main.yml` starts with the six standard
lines: `app_name` (the role name without its prefix, e.g. `gitlab_runner` for
`k3s_gitlab_runner`), `app_path` (`storage_base_path/app_name`), `app_user`
(`app_name` with hyphens), `app_group` (`app_user`), `app_user_create`
(`false`) and `app_dir_extra` (`[]`). Each is overridable as
`<role>_name`, `<role>_path`, `<role>_user`, `<role>_group`,
`<role>_user_create` and `<role>_dir_extra`. Keep
shared tunable values in `defaults/main/00-general.yml`, role-prefixed tunable
values in additional `.yml.j2` defaults files, derived or role-internal values
in `vars/main.yml`, and role-specific templates under `templates/` when
needed. Empty optional directories are not generated.

## Task slots

The starter provides three conventional slots. They are comments only, so a
new role does not perform invented work before it is customized:

- `00-prepare.yml`: shared account and storage task (see below); identical in
  every role, never edited per role.
- `10-install.yml`: primary installation or deployment.
- `20-config.yml`: configuration, integrations, and post-install work.

Add more files with a two-digit prefix, such as `11-config.yml` or
`30-verify.yml`, when a role needs more separation. `tasks/main.yml` includes
them automatically; do not manually include the numbered files from another
task file.

## Data directories

`tasks/00-prepare.yml` creates a system user and group (no home) when
`app_user_create` is true, then `app_path` and every item of `app_dir_extra`
in one task. Each item has `name` (relative to `app_path`) and optional
`owner` and `group` (default `app_user`/`app_group` when `app_user_create`,
else `root`/`storage_group`), `mode` (default `0700`) and `recurse` (default
`false`). `app_path` itself always gets these defaults. Set the role's directories in
`<role>_dir_extra` in defaults. Other prerequisites and checks go into a later
file such as `05-validate.yml`. A role that stores nothing on the host deletes
`00-prepare.yml` and keeps the `app_*` lines.

## Customize

- Replace the placeholder comments in the numbered task files.
- Add role-specific defaults as additional numbered files under
  `defaults/main/`.
- Use `.yml.j2` for defaults that need Galaxy to substitute `{{ role_name }}`
  into a role-prefixed variable name. Use plain `.yml` for runtime Ansible
  Jinja and for files that need no Galaxy substitution.
- Keep the shared `tasks/main.yml` entry point unless the role has a documented
  reason to diverge.
- Keep the six generated `app_*` lines in `vars/main.yml` unchanged; add
  other derived values below them and put operator-tunable values in
  `defaults/`.
- Add `meta/main.yml` platform entries and dependencies for the role.
- Update the generated README with variables, requirements, dependencies,
  examples, and verification steps.
- Add `handlers/main.yml` and templates only when the role needs them.

The skeleton intentionally has no application-specific defaults or runtime
implementation. Its generic `app_*` values and data directory task keep it
useful for OS, container, Kubernetes, Proxmox, and other non-Windows roles
without making a false assumption about what the role installs.

## Verification

```bash
ansible-playbook --syntax-check <playbook>.yml
ansible-lint roles/<role_name>/
yamllint roles/<role_name>/
```

## License

MIT. See the collection repository license.

## Author

knelldev
