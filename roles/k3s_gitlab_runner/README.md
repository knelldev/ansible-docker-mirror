K3s GitLab Runner
=================

Deploys disposable GitLab Runner Helm releases with Kubernetes executors and
optional T-shirt-sized runner pools.

Requirements
------------

Requires Ansible Core 2.17 or newer, K3s with a working kubeconfig, Helm, and
the `kubernetes.core` collection. GitLab API-managed runners additionally
require a suitable API token. S3 cache storage is optional and external.

Role Variables
--------------

| Variable                                           | Default            | Purpose                                 |
| -------------------------------------------------- | ------------------ | --------------------------------------- |
| `k3s_gitlab_runner_namespace`                      | `gitlab-runner`    | Runner manager namespace                |
| `k3s_gitlab_runner_tshirt_enabled`                 | `true`             | Enable automatic size pools             |
| `k3s_gitlab_runner_management_tag`                 | `ansible`          | Ownership tag                           |
| `k3s_gitlab_runner_description_prefix`             | `""`               | Optional custom-runner ownership prefix |
| `k3s_gitlab_runner_prune_stale_enabled`            | T-shirt enablement | Remove stale managed instance runners   |
| `k3s_gitlab_runner_reset_managed_instance_runners` | `false`            | Recreate all managed instance runners   |
| `k3s_gitlab_runner_ephemeral_storage_enabled`      | `false`            | Optional job disk limits                |
| `k3s_gitlab_runner_hooks_enabled`                  | `true`             | Resource report hooks                   |
| `k3s_gitlab_runner_metrics_enabled`                | `false`            | Runner manager metrics                  |

T-shirt runners retain generated `docker-<size>`, `k8s-<size>`, and
`shared-<size>` tags plus `ansible`. Custom runner tags are additive.
The role keeps `run_untagged` enabled.

T-shirt eligibility allows Linux-reported memory to be below a nominal threshold
by the greater of 512 MiB or 5 percent of that threshold. A 6 GB Proxmox guest
reporting 5660 MiB therefore selects `xs`, `s`, and `m`; resource requests and
calculated job capacities continue to use the actual reported memory.

Runner Lifecycle
----------------

When T-shirt generation is enabled, stale GitLab cleanup is enabled by default.
Set `k3s_gitlab_runner_prune_stale_enabled: false` to retain stale registrations.
Cleanup reads every GitLab API page and deletes only `instance_type` runners with
both the exact `ansible` management tag and the role-owned description prefix.
Project runners, group runners, unmarked instance runners, and supplied-token
runners are preserved. With the compatibility default prefix, lifecycle
operations own generated `k8s-runner-` T-shirt descriptions only. Set an explicit
`k3s_gitlab_runner_description_prefix` to adopt API-managed custom runners.

To recreate role-owned instance runners once, run with:

    k3s_gitlab_runner_reset_managed_instance_runners: true

Reset clears saved values only for desired API-managed instance runners, deletes
matching GitLab registrations, and updates existing Helm releases with newly
resolved tokens. It does not uninstall releases or delete namespaces, project or
group runners, supplied-token runners, hooks, or cache data. Set the flag back to
`false` immediately after the reset run; leaving it enabled recreates runners on
every run.

Successful runs end with a secret-safe structured summary containing cluster and
T-shirt decisions, cleanup/reset counts, and per-runner identity, configuration,
capacity, resource, and observed-health outcomes. `not checked` is reported when
the successful path did not perform a health check. Tokens, rendered values, and
credential-bearing URLs are never included.

Dependencies
------------

No role dependencies. The role reads shared `storage_base_path`, `http`, and
GitLab URL defaults from the repository.

Example Playbook
----------------

    - hosts: k3s_servers
      roles:
        - k3s_gitlab_runner

License
-------

MIT

Author Information
------------------

Maintained by the repository contributors.
