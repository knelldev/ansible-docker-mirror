## Why

The custom stdout callback already displays the source filename for normal task
and handler banners. Role task names still repeat filenames or interpolate a
`task_filename` variable, which makes output redundant and can require an
undefined variable.

## What Changes

- Remove filename prefixes, `task_filename` interpolation, and redundant
  quoting from role task names.
- Normalize role task names to capitalized action descriptions.
- Apply the same plain-name contract to the role skeleton so generated roles do
  not reintroduce the workaround.
- Retain callback-owned source prefixes without changing target-host behavior.

## Scope

- All role task files and the repository role skeleton.
- The existing source-prefixed callback output specification.

## Exclusions

- Callback behavior, task execution logic, role variables other than removing
  the obsolete name interpolation, and unrelated task-name wording.

## Approval

- Approved for implementation by the user on 2026-08-13.
