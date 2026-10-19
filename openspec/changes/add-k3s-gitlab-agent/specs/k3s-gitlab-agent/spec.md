## ADDED Requirements

### Requirement: Agent registration

The role SHALL register each configured agent in its config project through
the GitLab REST API when no agent of that name exists, and SHALL reuse an
existing agent of that name.

#### Scenario: New agent

- **WHEN** the config project has no agent with the configured name
- **THEN** the role creates it and installs agentk for it

#### Scenario: Existing agent

- **WHEN** the agent exists and its token Secret is present in the cluster
- **THEN** the role creates no agent and no token

### Requirement: Token handling

The role SHALL keep the agent token only in a Kubernetes Secret in the agent
namespace, SHALL pass it to the chart by Secret name, and SHALL never show it
in task output, Helm values or files on the target.

#### Scenario: Missing token Secret

- **WHEN** the agent exists but its token Secret is absent
- **THEN** the role creates one token and writes it to the Secret before
  installing the chart

#### Scenario: Rotation

- **WHEN** the rotation flag is set
- **THEN** the role creates a new token, updates the Secret, rolls the pods
  through the token id in the pod annotations, waits for ready agentk pods,
  and revokes the agent's other active tokens

### Requirement: Namespace-scoped permissions

The role SHALL disable the chart's cluster-wide RBAC and SHALL grant the agent
ServiceAccount permissions only through a Role or RoleBinding in each listed
target namespace.

#### Scenario: Default install

- **WHEN** an agent is installed
- **THEN** no ClusterRoleBinding names its ServiceAccount

#### Scenario: Target without rights

- **WHEN** a target namespace has neither `rules` nor `cluster_role`
- **THEN** the role fails before changing the cluster

### Requirement: Versions

The role SHALL install the latest chart and an agentk image tag matching the
GitLab server version, unless the inventory pins either one.

#### Scenario: Default install

- **WHEN** no chart version and no image tag are set
- **THEN** Helm installs the latest chart and agentk uses `v<major.minor.patch>`
  of the GitLab server

#### Scenario: Pinned

- **WHEN** a chart version or an image tag is set
- **THEN** the release uses that value

### Requirement: Deployment health

The role SHALL wait for ready agentk pods and, on failure, SHALL print pod
logs and events without credentials.

#### Scenario: Pod not ready

- **WHEN** agentk pods are not ready within the timeout
- **THEN** the role fails and shows the last log lines and events
