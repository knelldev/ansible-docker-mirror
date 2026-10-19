## Why

The branch includes an incomplete role skeleton, collection metadata, and a
templated license. These are not required for the current runner deployment
and are unsafe to ship without identity and packaging decisions.

## What Changes

- Explicitly defer role skeleton and Galaxy packaging implementation.
- Prevent incomplete metadata and templated legal content from becoming release artifacts.
- Record the decisions required before restarting this work.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- None.

## Impact

- `roles/.skeletons/`, `galaxy.yml`, `meta/runtime.yml`, `.collectionignore`, and `LICENSE.md`.
- No runtime deployment behavior changes.

## Alternatives And Risks

- Completing packaging now would add identity, licensing, and distribution scope to an urgent deployment effort.
- Approval status: approved to defer and document only; no packaging implementation is authorized.
