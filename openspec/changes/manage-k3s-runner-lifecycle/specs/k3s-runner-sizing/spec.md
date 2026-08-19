## Purpose

Make generated T-shirt runner eligibility align with nominal host memory sizes
without changing the resource and capacity safeguards applied after selection.

## ADDED Requirements

### Requirement: Nominal-memory eligibility allowance

When T-shirt generation is enabled, the role SHALL treat reported node memory
as satisfying a size's nominal threshold when the shortfall is no greater than
the larger of 512 MiB or 5 percent of that threshold.

#### Scenario: Nominal 6 GB node reports slightly less usable memory

- **WHEN** the smallest target host reports 5660 MiB for the `m` size's 6144 MiB threshold
- **THEN** the role SHALL include `m` in the selected T-shirt runners

#### Scenario: Host remains outside allowance

- **WHEN** the smallest target host remains below both the fixed and proportional allowance boundaries for a size
- **THEN** the role SHALL exclude that size from deployment

### Requirement: Allowance affects selection only

The memory allowance SHALL NOT alter runner memory requests, CPU requests,
calculated job limits, capacity-pool percentages, system reservations, or
ephemeral-storage limits.

#### Scenario: Size qualifies through allowance

- **WHEN** a T-shirt size is selected because reported memory falls within the allowance
- **THEN** the role SHALL apply the same resources and capacity calculation used when the exact nominal threshold is met

### Requirement: Smallest-host safety remains authoritative

T-shirt eligibility SHALL continue to use the smallest reported memory value
across the play hosts before applying the nominal-memory allowance.

#### Scenario: Mixed-memory play hosts

- **WHEN** one play host remains below a size's tolerated threshold even though other hosts meet it
- **THEN** the role SHALL exclude that size
