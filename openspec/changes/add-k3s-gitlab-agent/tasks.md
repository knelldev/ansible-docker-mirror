## Status

- Approval: approved by the user on 2026-10-18 to build with offline checks
  only. Not approved: git commit, push, any run against a real cluster or the
  GitLab API.
- Plan state: built; offline verification done (2.1-2.3). 2.4 and 2.5 open.
- Blocker for 2.4/2.5: separate approval for a lab run; KAS reachable at the
  inventory's KAS address (lab: `ws://10.0.10.25:8150`).

## 1. Role

- [x] 1.1 Generate `roles/k3s_gitlab_agent/` from the role skeleton; defaults,
      vars, README, AGENTS.
- [x] 1.2 Add `playbooks/k3s_gitlab_agent.yml`.
- [x] 1.3 Input asserts: unique agent names, project set, every target with
      `rules` or `cluster_role`, allowed KAS scheme; the API token via the
      shared `__REQUIRED__` check.
- [x] 1.4 Registration: find or create the agent; token Secret reuse or
      create (`no_log`).
- [x] 1.5 Namespaces, Role/RoleBinding per target namespace.
- [x] 1.6 Helm install from a values file in `app_path` (latest chart and
      server-version image unless pinned), `rbac.create: false`,
      `config.secretName`, KAS address and optional CA, monitoring switch.
- [x] 1.7 Automatic replica count from schedulable nodes (as the runner). Health check, failure diagnostics, secret-safe summary.
- [x] 1.8 Rotation flag: new token, Secret update, rollout via the token id
      in `podAnnotations`, revoke others.
- [x] 1.9 Update `roles/AGENTS.md` index and the root README playbook list.

## 2. Verification

- [x] 2.1 `ansible-lint` (production) and `yamllint` on role and playbook.
- [x] 2.2 `ansible-playbook --syntax-check playbooks/k3s_gitlab_agent.yml`.
- [x] 2.3 Render the chart (`helm template`, 2.33.0) with the role's
      values: no ClusterRole(Binding), token only via Secret name.
- [ ] 2.4 Lab run (needs approval): agent connects; agentk logs show no
      `forbidden` in its own namespace; a CI job in the config project runs
      `kubectl auth can-i` in the target namespace (yes) and cluster-wide (no).
- [ ] 2.5 Rerun is unchanged; rotation run leaves one active token.

## Verification Evidence

Run 2026-10-18 in the worktree, offline (no cluster, no GitLab API).

- 2.1 `ansible-lint --offline roles/k3s_gitlab_agent playbooks/k3s_gitlab_agent.yml`
  (ansible-lint 26.10.1, core 2.21.5): `Passed: 0 failure(s), 0 warning(s) in
12 files ... Profile 'production' was required, and it passed.` It prints
  `resolved_fqcn` warnings for `kubernetes.core` modules because the
  collection is not in `./collections`; the existing `k3s_gitlab_runner` role
  shows the same. `yamllint roles/k3s_gitlab_agent playbooks/k3s_gitlab_agent.yml`
  (1.38.0): no findings. `prettier --check` on the new files: clean.
- 2.2 `ansible-playbook --syntax-check playbooks/k3s_gitlab_agent.yml`:
  `playbook: playbooks/k3s_gitlab_agent.yml`, rc 0.
- 2.3 Chart `gitlab-agent` 2.33.0 pulled from `https://charts.gitlab.io`
  (scratch Helm home, Helm 4.3.0). `values.yaml.j2` rendered by Ansible with a
  sample vars file (dummy names, dummy API token), then `helm template`:
  - 2 replicas, default KAS: kinds Deployment, Service, ServiceAccount; 0
    ClusterRole/ClusterRoleBinding; no chart Secret; `serviceAccountName:
demo-app-agentk`; `secretName: demo-app-token`; image `agentk:v19.5.0`;
    `--kas-address=wss://gitlab.example.test/-/kubernetes-agent/`;
    soft pod anti-affinity.
  - 1 replica, KAS override and CA: adds a ConfigMap and
    `--kas-ca-cert-file`; still 0 ClusterRole/ClusterRoleBinding.
  - Dummy API token string found 0 times in values and rendered manifests.
  - For comparison, chart defaults render 1 ClusterRole and 2
    ClusterRoleBindings (`rbac.create` and OCS); see design correction.
- Extra: `00-prepare.yml` run offline against localhost: a target without
  rights, a target with both `rules` and `cluster_role`, duplicate agent
  names and an invalid name each fail; a valid list passes.
- Extra: the token-id and summary expressions of `agent.yml` evaluated with
  mocked API responses (reuse, rotation at the two-token limit, missing
  Secret, Secret without annotation) give the expected ids and counts.
- Not verified: GitLab API status codes for POST/DELETE (the docs give
  none; the role accepts 200/201 and 200/204), pagination of the agent and
  token lists (the role reads one page of 100), whether agentk needs rights
  in its own namespace (2.4).

Rework 2026-10-19 (owner review), offline: KAS from parts, no pins, values
file on the host, rotation via `podAnnotations`, no `set_fact`, monitoring
switch, shared `__REQUIRED__` check fixed in all roles. Re-run of 2.1-2.3,
plus the agent flow against a mocked GitLab API and cluster (first run,
rerun creates nothing, two rotations, extra token at the limit, missing
Secret at the limit, unready rollout). The evidence above is from the first
build.

## Next Action

- User review of the built role; then approval for the lab run (2.4, 2.5).
