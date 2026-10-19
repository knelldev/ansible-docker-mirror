# Ansible Role: pve_vm_clone

This role clones a Proxmox VE virtual machine from a template, configures it using Cloud-Init, and waits for it to become accessible.

Requirements
------------

- The `community.general` Ansible collection must be installed (`ansible-galaxy collection install community.general`).
- Proxmox connection details (`proxmox_api_host`, `proxmox_api_user`, `proxmox_api_password`) must be provided, typically in your inventory's group or host variables.
- A VM template with Cloud-Init and the QEMU Guest Agent installed is required.

Role Variables
--------------

The role's behavior is controlled by variables defined in `defaults/main/10-pve.yml`. You can override these in your playbook or inventory.

### Main Configuration

- `pve_vm_clone_node`: The Proxmox node to operate on. (Default: `pve`)
- `pve_vm_clone_template`: The name of the template to clone from. (Default: `ubuntu-2204-cloudinit-template`)
- `pve_vm_clone_vm_name`: The name for the new VM. (Default: `ansible-vm`)
- `pve_vm_clone_vmid`: (Optional) The VMID for the new VM. If omitted, Proxmox will choose the next available ID.
- `pve_vm_clone_pool`: (Optional) The resource pool to assign the new VM to.

### VM Sizing

- `pve_vm_clone_cores`: (Optional) Number of CPU cores.
- `pve_vm_clone_memory`: (Optional) Amount of RAM in MB (e.g., `2048`).
- `pve_vm_clone_disk_storage`: The storage pool for the VM's disk. (Default: `local-lvm`)
- `pve_vm_clone_disk_size`: (Optional) The size of the disk (e.g., `50G`). If omitted, the template's disk size is used.
- `pve_vm_clone_disk_format`: The disk format. (Default: `qcow2`)
- `pve_vm_clone_clone_type`: Type of clone. Can be `full` or `linked`. (Default: `full`)

### Network & Cloud-Init

- `pve_vm_clone_ssh_port`: The SSH port to wait for. (Default: `22`)
- `pve_vm_clone_timeout`: Timeout in seconds for the Proxmox create/clone operation. (Default: `300`)
- `pve_vm_clone_ci_user`: The Cloud-Init user to create. (Default: `ubuntu`)
- `pve_vm_clone_ci_ssh_key`: **Required.** The public SSH key content to inject for the user.
- `pve_vm_clone_ci_ip`: (Optional) The static IP address for the VM.
- `pve_vm_clone_ci_netmask`: The netmask in CIDR format. (Default: `24`)
- `pve_vm_clone_ci_gateway`: (Optional) The gateway address for the VM.
- `pve_vm_clone_ci_ipconfig`: (Advanced) A full `ipconfig` string to override the partial network settings above.
- `pve_vm_clone_ci_nameserver`: (Optional) DNS nameserver.
- `pve_vm_clone_ci_searchdomain`: (Optional) DNS search domain.

Dependencies
------------

None.

Idempotency and Behavior
------------------------

The role is designed to be safely run multiple times.

- **If a VM with the specified `pve_vm_clone_vm_name` does not exist:** It will be created by cloning the template.
- **If a single VM with the name already exists:** The role will not re-clone it. Instead, it will ensure the VM's configuration (cores, memory, etc.) matches the variables provided to the role and that the VM is in a `started` state.
- **If multiple VMs with the same name exist:** The role will fail. This is a safety measure to prevent ambiguous operations on the wrong machine. To manage a specific VM in this case, you must provide its unique `pve_vm_clone_vmid`.

Example Playbook
----------------

```yaml
- hosts: localhost
  connection: local
  gather_facts: false
  vars:
    # Proxmox API connection
    proxmox_api_host: "pve.example.com"
    proxmox_api_user: "root@pam"
    proxmox_api_password: "{{ vault_proxmox_api_password }}"

    # VM specific overrides
    pve_vm_clone_vm_name: "web-server-01"
    pve_vm_clone_template: "ubuntu-2204-template"
    pve_vm_clone_cores: 2
    pve_vm_clone_memory: 4096
    pve_vm_clone_disk_size: "40G"
    pve_vm_clone_ci_ip: "192.168.1.100"
    pve_vm_clone_ci_gateway: "192.168.1.1"
    pve_vm_clone_ci_nameserver: "1.1.1.1"
    pve_vm_clone_ci_ssh_key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"

  roles:
    - role: pve_vm_clone
```

License
-------

BSD

Author Information
------------------

This role was created by the team at knell.dev.
