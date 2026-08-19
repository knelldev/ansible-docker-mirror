# Recovery Records

## Purpose

Stores actionable handoffs for recovering mixed or unsafe repository state.

## Ownership

- Each record owns one bounded recovery effort.

## Local Contracts

- State observed facts separately from recommendations.
- Include source paths and verification gaps.
- Never present unverified behavior as confirmed.

## Work Guidance

- Preserve the source branch until each retained change is independently verified.

## Verification

- Reconcile the record with `git status`, `git log`, and relevant checks before acting on it.

## Child DOX Index

- None.
