## Context

The role must fit the Linux role skeleton and remain composable with
`os_prepare`, `os_container`, and future `os_mount` work. Operational runs
should be traceable through the setup described in `docs/execution.md`.

## Decisions Required

1. Select supported distributions and minimum kernel/systemd capabilities.
2. Separate safe baseline settings from provider-specific tuning.
3. Define whether monitoring is configured, only verified, or delegated.
4. Define explicit opt-in variables for sysctl, limits, timers, and services.
5. Define rollback and one-host verification before wider execution.

## Verification Shape

Static checks must cover syntax, lint, variable validation, and rendered
configuration. Controlled host checks must verify effective settings, service
health, connectivity, and repeat-run stability.

## Decision 2026-10-19 (owner)

The VPS baseline is `os_prepare` + `os_wg`; there is no separate `os_vps`
role. The `roles/os_vps/` contract stub is removed. Tuning or hardening found
missing later goes into `os_prepare` as an optional part (like its nftables
allowlist) or into a role of its own.
