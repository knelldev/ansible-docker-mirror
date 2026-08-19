## ADDED Requirements

### Requirement: Framework responsibilities remain separate

The project guidance MUST state that DOX always governs target paths and local
contracts, while OpenSpec governs material technical intent, requirements, and
verification. The guidance MUST NOT replace or weaken either framework.

#### Scenario: One change has multiple boundaries

- **WHEN** a change touches paths with different applicable `AGENTS.md` chains
  or independent behaviors
- **THEN** the guidance permits multiple DOX chains and independent OpenSpec
  specs without forcing unrelated work into one contract

### Requirement: OpenSpec use is proportional

The project guidance MUST require full OpenSpec artifacts for material changes
and permit a lightweight path for small isolated work with an obvious existing
contract. It MUST default to full OpenSpec when materiality is uncertain.

#### Scenario: New behavior is requested

- **WHEN** work adds or changes behavior, architecture, compatibility, risk,
  security, dependencies, integrations, migrations, or project standards
- **THEN** the guidance requires a full OpenSpec change before implementation

#### Scenario: Existing behavior has a small isolated defect

- **WHEN** a small fix has an obvious expected result and preserves its existing
  contract and boundary
- **THEN** the guidance permits a lightweight plan with equivalent validation

#### Scenario: Approved implementation requires documentation updates

- **WHEN** documentation must be updated to describe behavior already covered
  by an approved implementation
- **THEN** the documentation update stays within that change unless it adds
  additional behavior or establishes a new contract

### Requirement: Approval covers the bounded outcome

The project guidance MUST require explicit approval before planned execution
and MUST define approval as covering the goal and approach rather than an
immutable task list. An optional `Authority` field MAY clarify permission when
needed but MUST NOT replace approval or applicable contracts.

#### Scenario: Implementation detail changes

- **WHEN** a task adapts without changing the approved goal, design, paths, or
  risk boundary
- **THEN** implementation may continue without repeated approval

#### Scenario: Material scope changes

- **WHEN** the goal, design, allowed paths, risk, dependency, privilege,
  compatibility promise, or external system changes
- **THEN** work stops and approval is requested again

### Requirement: Closeout is evidence-based

The project guidance MUST define automatic validation closeout only when the
goal is met, validation passes, applicable DOX chains are rechecked, records
are complete, and no material uncertainty remains. It MUST retain the required
final outcome confirmation before durable DOX closeout, synchronization, or
archival. Durable closeout MUST report implementation, validation, DOX and
OpenSpec status, documentation, quality, unexpected items, banked ideas, and
one next action.

#### Scenario: Closeout has an unresolved issue

- **WHEN** a check fails, a path is unexpected, a record is incomplete, or a
  material risk remains unreviewed
- **THEN** closeout stops and reports the issue and decision needed
