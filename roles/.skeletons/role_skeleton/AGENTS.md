# Role Skeleton

## Purpose

Generic non-Windows starter consumed by `ansible-galaxy role init` for roles in
the `knelldev.rituals` collection.

## Local Contracts

- `defaults/main/00-general.yml` contains shared defaults only. Preparation
  defaults, including the derived `app_user_create` switch, stay in
  `tasks/00-prepare.yml`.
- Defaults files that contain `{{ role_name }}` for Galaxy initialization use
  `.yml.j2`; runtime-only Jinja stays in plain `.yml` files.
- Numbered files under `tasks/` are static YAML extension slots: `00-prepare`,
  `10-install`, and `20-config`.
- `tasks/main.yml` is the repository-standard entry point. It performs
  role-prefixed sentinel validation, loads optional OS vars with
  `with_first_found`, and discovers numbered tasks with a sorted `fileglob`
  loop. This same file is currently used by every role, including Windows
  roles; the skeleton itself remains non-Windows because its defaults and
  platform metadata target Linux.
- `vars/main.yml` is a plain role-internal variable entry point. It provides
  the derived `app_name`, `app_path`, `app_user`, and `app_group` values used by
  the default preparation task; preserve or extend them when the role needs
  more derived values. Optional role-prefixed identity overrides are resolved
  there, not duplicated in task vars. The derived path may be overridden there
  when a role needs storage outside the standard `storage_base_path`.
- `meta/main.yml.j2` and role-prefixed defaults files are init-time templates;
  generated runtime task YAML remains static.
- `tasks/00-prepare.yml` creates the configured storage directories and is the
  place for additional prerequisites and target preparation. It optionally
  creates a system user and matching system group when enabled by the
  derived `app_user_create` switch, with storage ownership defaulting to
  that account or root. Role-specific user and group overrides are optional
  vars, not defaults; do not duplicate `app_group` in `vars/main.yml`.
- `handlers/` is omitted until the role needs handlers.
- The skeleton does not assume Quadlet, containers, Kubernetes, Proxmox, or a
  specific application.
- The initial documented platform baseline is EL 9 and EL 10. Individual roles
  must declare their actual supported platforms in generated `meta/main.yml`.

## Verification

```bash
ansible-galaxy role init test_skel \
  --role-skeleton=./roles/.skeletons/role_skeleton \
  --init-path=./.skel-out --offline --force
yamllint ./.skel-out/test_skel/ roles/.skeletons/role_skeleton/
ansible-lint --nocolor --profile production --offline roles/.skeletons/role_skeleton/
ansible-lint --nocolor --profile production --offline ./.skel-out/test_skel/
```

## Child DOX Index

None.
