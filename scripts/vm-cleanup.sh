#!/usr/bin/env bash
set -euo pipefail

# Remove traces of MAC address and UUID from network configuration
if [ -e /etc/sysconfig/network-scripts ]; then
  find /etc/sysconfig/network-scripts -maxdepth 1 -mindepth 1 -type f -name 'ifcfg-e*' -print0 | xargs -0 -I{} sed -E -i '/^(HWADDR|UUID)/d' '{}'
fi

# Disable root login through ssh with a key
pam_files=(
  /etc/pam.d/system-auth
  /etc/pam.d/password-auth-ac
  /etc/pam.d/password-auth
  /etc/pam.d/system-auth-ac
)
for file in "${pam_files[@]}"; do
  if [ -e "$file" ]; then
    sed -i 's/nullok//g' "$file"
  fi
done

# Lock root account
passwd -d root
passwd -l root

# Remove default ssh host keys
find /etc/ssh -maxdepth 1 -mindepth 1 -type f -name 'ssh_host*_key*' -delete
for key_type in rsa dsa ecdsa; do
  ssh-keygen -t "${key_type}" -f /etc/ssh/ssh_host_"${key_type}"_key -N ''
done

# Zero out the free space to save space in the final image
dd if=/dev/zero of=/EMPTY bs=1M 2>&1 || true
rm -f /EMPTY

# Clear history
history -c
