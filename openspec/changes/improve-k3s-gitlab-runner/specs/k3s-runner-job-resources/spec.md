## Purpose

This capability provides optional, disposable job-resource protection and concise per-job resource reporting while preserving the existing T-shirt memory sizing and recommendation behavior.

## ADDED Requirements

### Requirement: Optional automatic ephemeral storage sizing
When enabled, the role SHALL assign each T-shirt runner an ephemeral-storage limit derived from the lowest node disk capacity, a fixed safety buffer, and the configured runner concurrency. The calculated limit SHALL increase with runner size and SHALL remain bounded by the configured size limit. Persistent workspace volumes SHALL NOT be introduced.

#### Scenario: Automatic storage sizing is disabled
- **WHEN** ephemeral storage sizing is disabled
- **THEN** the role SHALL preserve the current job storage behavior

#### Scenario: Automatic storage sizing is enabled
- **WHEN** ephemeral storage sizing is enabled on a single-purpose runner cluster
- **THEN** the role SHALL calculate disposable per-job storage from the lowest node capacity and concurrency while retaining a safety buffer and T-shirt size bounds

### Requirement: Job report includes disk usage
When hooks are enabled, the post-build report SHALL retain the existing duration, memory, CPU, and T-shirt recommendation output and SHALL additionally report disk availability and workspace or temporary-directory usage when those measurements are available.

#### Scenario: Job completes normally
- **WHEN** the post-build hook runs after a normal job
- **THEN** the log SHALL contain the existing resource report plus disk-related measurements

#### Scenario: Disk measurement is unavailable
- **WHEN** a job image does not expose a readable disk measurement
- **THEN** the hook SHALL preserve the report and identify the unavailable measurement without failing the job

### Requirement: Compact machine-readable job metrics
The post-build hook SHALL emit one compact, stable metrics line containing the available duration, memory, CPU, and disk measurements. The metrics line SHALL not replace the human-readable report.

#### Scenario: Metrics are available
- **WHEN** the post-build hook has collected resource data
- **THEN** it SHALL emit one parseable `RUNNER_METRICS` line with the available values

#### Scenario: Metrics are partial
- **WHEN** one or more measurements are unavailable
- **THEN** the hook SHALL emit the metrics line with explicit unavailable values and SHALL not fail the job

### Requirement: Configurable hook sampling
The resource monitor SHALL use a configurable sampling interval while retaining the current interval as the default. Memory recommendation thresholds SHALL remain configurable without changing the current default thresholds.

#### Scenario: Custom sampling interval
- **WHEN** an operator sets a positive sampling interval
- **THEN** the monitor SHALL sample at that interval

#### Scenario: Defaults are unchanged
- **WHEN** no hook interval or threshold override is configured
- **THEN** the monitor SHALL retain the current five-second sampling interval and 80/40 percent recommendation thresholds
