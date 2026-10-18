# pve_ct_template

Builds, tests and replaces Proxmox LXC templates through the Proxmox API.
Defaults build `ct-alma-10-dmz` (bridge `vmbr1`) and `ct-alma-10-int`
(full clone, bridge `vmbr0`) from the newest stock AlmaLinux 10 image.
Driven by `playbooks/pve_ct_template.yml`; plan and decisions:
`openspec/changes/add-ct-template/`.

## Requirements

- Ansible core 2.17 or newer, collection `community.proxmox` `>=2.0.0`.
- Proxmox API token (default `automation@pve!lxc-template`) with rights to
  read the node, download templates to the image storage, and create,
  clone, configure and destroy guests in the pool.
- The controller reaches the guests' DHCP addresses over SSH.
- Guests: AlmaLinux 10 (EL 10) with Python 3.

## Role variables

Secrets default to environment variables (`defaults/main/10-api.yml`), so
Semaphore can set them now and another secret store later:

| Variable                           | Environment variable                           | Default          |
| ---------------------------------- | ---------------------------------------------- | ---------------- |
| `pve_ct_template_api_host`         | `PROXMOX_HOST`                                 | none (required)  |
| `pve_ct_template_api_user`         | `PROXMOX_USER`                                 | `automation@pve` |
| `pve_ct_template_api_token_id`     | `PROXMOX_TOKEN_ID`                             | `lxc-template`   |
| `pve_ct_template_api_token_secret` | `PROXMOX_TOKEN_SECRET`                         | none (required)  |
| `pve_ct_template_build_pubkey`     | `PVE_CT_TEMPLATE_BUILD_PUBKEY`                 | none (required)  |
| `pve_ct_template_build_key_file`   | `PVE_CT_TEMPLATE_BUILD_KEY_FILE`               | none (required)  |
| `pve_ct_template_admin_pubkeys`    | `PVE_CT_TEMPLATE_ADMIN_PUBKEYS` (one per line) | none (required)  |
| `pve_ct_template_admin_key_file`   | `PVE_CT_TEMPLATE_ADMIN_KEY_FILE`               | none (required)  |

Other values (`defaults/main/20-ct.yml`): node (`pve`, allowed `pve`/`pve2`),
image storage (`pve-z2`) and name pattern, guest names and the `ct-` guard
prefix, pool (`Templates`), bridges, CPU, memory, swap, features
(`nesting=1`), rootfs 15 GiB and `mp0` 35 GiB at `/data` on `pve-ssd`,
timeouts, notes length, and the clone-test image, DNS name and metrics URL.

## Phases

The role has no numbered task files; the playbook calls one phase file per
play with `tasks_from`:

| File                                  | Runs on    | Does                                                                                                                          |
| ------------------------------------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `phase_build.yml`                     | localhost  | checks, records old templates, removes leftovers, downloads the image (node-side), creates and starts the build CT            |
| `guest_stock.yml`, `guest_record.yml` | build CT   | package lists, build identity, Alma version                                                                                   |
| `phase_template.yml`                  | localhost  | notes, dmz template, int full clone and template, test clone                                                                  |
| `guest_test.yml`                      | test clone | identity differs, route, DNS, sshd, node_exporter metrics, rootless `podman run`                                              |
| `phase_finish.yml`                    | localhost  | success: remove test clone and old templates not being cloned; failure: remove all guests this run created; then fail the run |

Every stop or destroy goes through `destroy.yml`: LXC only, name starts with
the prefix, VMID created or recorded by this run.

## Dependencies

None in `meta/main.yml`. The playbook also runs `os_prepare`, `os_container`
and `os_template_reset` in the build CT.

## Example playbook

See `playbooks/pve_ct_template.yml`. Run:

```bash
export PROXMOX_HOST=pve.example.internal PROXMOX_TOKEN_SECRET=...
export PVE_CT_TEMPLATE_BUILD_PUBKEY="$(cat build.pub)" PVE_CT_TEMPLATE_BUILD_KEY_FILE=./build
export PVE_CT_TEMPLATE_ADMIN_PUBKEYS="$(cat localadmin.pub)" PVE_CT_TEMPLATE_ADMIN_KEY_FILE=./localadmin
ansible-playbook playbooks/pve_ct_template.yml
```

## License

MIT. See the collection repository license.

## Author

knelldev
