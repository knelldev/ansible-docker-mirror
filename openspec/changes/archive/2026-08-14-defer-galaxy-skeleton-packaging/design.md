## Context

The repository already uses a common non-Windows role shape: shared defaults,
numbered task files discovered by `tasks/main.yml`, and a `vars/main.yml`
entry point. The existing skeleton instead embeds a complete Quadlet example,
which is too opinionated for a collection containing OS, container, Kubernetes,
and infrastructure roles.

## Goals / Non-Goals

**Goals:**

- Produce a valid generic starting point for any non-Windows role.
- Make `knelldev.rituals` buildable and accurately documented.
- Preserve runtime Jinja templates only where Galaxy role initialization needs
  to substitute `role_name`.

**Non-Goals:**

- Refactor existing roles to collection layout.
- Standardize Windows roles on the non-Windows skeleton.
- Ship a generic Quadlet, container, or systemd implementation in every role.

## Decisions

- Use `knelldev.rituals` as the namespace/name pair. It describes a collection
  of repeatable automation practices without narrowing future role categories.
- Use `MIT` for collection and role metadata, with `knelldev` as author.
- Make the skeleton platform-neutral at task level, with EL 9 and EL 10 as the
  initial documented baseline for non-Windows role consumers.
- Keep `defaults/main/00-general.yml`, `tasks/00-prepare.yml`,
  `tasks/10-install.yml`, `tasks/20-config.yml`, `tasks/main.yml`, and
  `vars/main.yml`. The numbered files are intentionally empty extension slots
  apart from concise guidance comments; the starter must not perform arbitrary
  work when generated.
- Remove the Quadlet templates, handler, and rootless deployment instructions
  from the skeleton. Role-specific templates and handlers belong in the role
  that needs them.
- Keep `meta/main.yml.j2` as the only role-init template because it needs the
  generated role name. Runtime task/default/vars files remain static YAML.

## Risks / Trade-offs

- The starter provides structure rather than a working application. This is
  safer and more reusable, but generated roles need role-specific implementation.
- Galaxy collection packaging does not encode one platform matrix for all roles;
  individual role metadata remains responsible for its actual platforms.

## Verification

- Generate a test role with `ansible-galaxy role init` and inspect its layout.
- Run YAML/lint checks on the skeleton and generated role.
- Build the collection with `ansible-galaxy collection build` and inspect the
  resulting artifact contents.
