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
discovers numbered task files in ascending order. The generated `vars/main.yml`
provides `app_name`, `app_path`, `app_user`, and `app_group`; `app_name` uses
the second component of `role_name` and `app_user` converts underscores to
hyphens. These identity values are derived in `vars/main.yml`, with optional
role-prefixed overrides. `00-prepare.yml` uses those values to create the configured storage
directories. It can also create a system group and user when the derived
`app_user_create` switch is set to `true`. It reads the optional
`<role_name>_user_create` input, which defaults to `false`. Keep shared
tunable values in `defaults/main/00-general.yml`, role-prefixed tunable values
in additional `.yml.j2` defaults files, derived or role-internal values in
`vars/main.yml`, and role-specific templates under `templates/` when needed.
Empty optional directories are not generated.

## Task slots

The starter provides three conventional slots. They are comments only, so a
new role does not perform invented work before it is customized:

- `00-prepare.yml`: optionally creates the configured group and user, creates
  the configured storage directories, and provides a place for more
  prerequisites.
- `10-install.yml`: primary installation or deployment.
- `20-config.yml`: configuration, integrations, and post-install work.

Add more files with a two-digit prefix, such as `11-config.yml` or
`30-verify.yml`, when a role needs more separation. `tasks/main.yml` includes
them automatically; do not manually include the numbered files from another
task file.

## Preparation defaults

`tasks/00-prepare.yml` contains lean task-local defaults for account creation
and storage. The default list contains one item with `name: ""`, which creates
the main `app_path`. Additional directories can be supplied with
`<role_name>_storage_extra_dirs`; each item can contain `name`, `owner`,
`group`, and `mode`. Values omitted from extra items use the task defaults.

`<role_name>_user_create` is an optional role-prefixed preparation input. Leave
it unset or set it to `false` for normal root-owned storage, or set it to `true`
when the role needs a system account. The derived `app_user_create` var is used
by the preparation tasks.

The user and group are created together or not at all. The derived identity
values are:

- `<role_name>_name` overrides `app_name`.
- `<role_name>_path` overrides `app_path`.
- `<role_name>_user` overrides `app_user`.
- `<role_name>_group` overrides `app_group`.

They are optional vars, not defaults.

## Customize

- Replace the placeholder comments in the numbered task files.
- Add role-specific defaults as additional numbered files under
  `defaults/main/`.
- Use `.yml.j2` for defaults that need Galaxy to substitute `{{ role_name }}`
  into a role-prefixed variable name. Use plain `.yml` for runtime Ansible
  Jinja and for files that need no Galaxy substitution.
- Keep the shared `tasks/main.yml` entry point unless the role has a documented
  reason to diverge.
- Preserve the generated `app_name`, `app_path`, `app_user`, and `app_group` values in
  `vars/main.yml`; add other derived values there and put operator-tunable
  values in `defaults/`.
- Override `<role_name>_user` or `<role_name>_group` in role vars only when the
  default `app_user` identity is not suitable.
- Add `meta/main.yml` platform entries and dependencies for the role.
- Update the generated README with variables, requirements, dependencies,
  examples, and verification steps.
- Add `handlers/main.yml` and templates only when the role needs them.

The skeleton intentionally has no application-specific defaults or runtime
implementation. Its generic `app_*` values and base directory task keep it
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
