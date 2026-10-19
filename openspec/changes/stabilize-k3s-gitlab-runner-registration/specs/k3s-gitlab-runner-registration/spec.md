## ADDED Requirements

### Requirement: Manual token deployment

The role SHALL deploy a runner when a runner item provides a valid runner
authentication token.

#### Scenario: Manual token runner

- **WHEN** a runner item provides its authentication token and no API credential
- **THEN** the role renders its Helm values and deploys the runner without calling the GitLab Runner API

### Requirement: API-managed token deployment

The role SHALL resolve one usable runner token through the validated GitLab API
flow before rendering Helm values when API-managed registration is selected.

#### Scenario: API-created runner

- **WHEN** a runner item requires API-managed registration and no matching runner exists
- **THEN** the role creates the runner through the validated scope endpoint and deploys Helm using the returned token

### Requirement: Rendered values drive deployment

The role SHALL render the values for a runner before supplying them to Helm.

#### Scenario: First deployment

- **WHEN** no saved values file exists for a runner
- **THEN** the role writes values using the resolved token and Helm deploys those rendered values

### Requirement: Safe reruns

The role SHALL not create a duplicate runner or rotate a token during an
unchanged rerun.

#### Scenario: Unchanged API-managed runner

- **WHEN** a matching runner and unchanged configuration already exist
- **THEN** the role reuses the validated registration state without duplication or rotation

#### Scenario: Missing managed state

- **WHEN** the target-side values file is missing but an exact runner description exists
- **THEN** the role rotates that runner's authentication token and deploys it without creating a duplicate

### Requirement: Runner connectivity verification

The role SHALL verify that an API-managed runner is online after deployment.

#### Scenario: API-managed runner starts

- **WHEN** Helm reports a successful release rollout
- **THEN** the role checks GitLab runner status and waits for `online`

### Requirement: Shared T-shirt deployment

The role SHALL process eligible T-shirt and custom runner definitions through one
registration and deployment flow.

#### Scenario: Undersized cluster

- **WHEN** a T-shirt size needs more memory than the smallest target node provides
- **THEN** the role excludes that size from deployment
