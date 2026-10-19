#!/bin/sh
# Managed by Ansible (os_prepare). Runs once per clone, before sshd:
# new machine-id and new SSH host keys. Marker: /var/lib/firstboot-identity.done
set -eu

if mountpoint -q /etc/machine-id; then
  # systemd generated a transient ID for an empty file; make it permanent
  systemd-machine-id-setup --commit
elif ! grep -qE '^[0-9a-f]{32}$' /etc/machine-id 2>/dev/null; then
  rm -f /etc/machine-id
  systemd-machine-id-setup
fi

rm -f /etc/ssh/ssh_host_*
ssh-keygen -A

touch /var/lib/firstboot-identity.done
