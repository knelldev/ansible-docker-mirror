## Status

- Approval: implementation approved by user on 2026-08-14.
- Plan state: in progress.
- Scope decision: use `knelldev.rituals` and a generic non-Windows role starter;
  omit the Quadlet example.

## Tasks

- [x] Separate skeleton and packaging work from urgent runtime recovery.
- [x] Confirm collection namespace/name (`knelldev.rituals`), author (`knelldev`),
      MIT license, and Galaxy distribution target.
- [x] Replace the Quadlet-specific skeleton with a generic non-Windows role
      contract based on the repository's defaults/tasks/vars layout.
- [x] Repair collection metadata, README, runtime requirements, and static MIT
      legal text.
- [x] Verify generated role layout, YAML/lint checks, collection build, and
      package contents.

## Verification Evidence

- `openspec validate defer-galaxy-skeleton-packaging --strict` passes.
- `ansible-galaxy role init test_skel --role-skeleton=./roles/.skeletons/role_skeleton --init-path=./.skel-out --offline --force` creates the expected generic role layout.
- `yamllint roles/.skeletons/role_skeleton .skel-out/test_skel` passes.
- `ansible-lint --nocolor --profile production --offline roles/.skeletons/role_skeleton .skel-out/test_skel` passes with zero failures and zero warnings.
- `ansible-galaxy collection build --force` creates `knelldev-rituals-1.0.0.tar.gz`.
- `ansible-galaxy collection install ... --force` installs `knelldev.rituals:1.0.0` successfully.
- Package inspection confirms repository working files, OpenSpec records, and
  the skeleton are excluded from the collection artifact.
- `git diff --check` passes for the changed plan, metadata, and skeleton files.

## Next Action

- Archive this completed change after the outcome is reviewed.
