#!/usr/bin/env bash
set -euo pipefail

# Remove traces of MAC address and UUID from network configuration
sed -E -i '/^(HWADDR|UUID)/d' /etc/sysconfig/network-scripts/ifcfg-e*

# Disable udev network rules
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules

# Disable root login through ssh with a key
sed -i 's/nullok//g' /etc/pam.d/system-auth /etc/pam.d/password-auth-ac /etc/pam.d/password-auth /etc/pam.d/system-auth-ac

# Lock root account
passwd -d root
passwd -l root

# Remove ssh host keys
rm -rf /etc/ssh/ssh_host*_key*

# Clean up /root
rm -f /root/anaconda-ks.cfg
rm -f /root/install.log
rm -f /root/install.log.syslog
rm -rf /root/.pki
rm -rf /root/.cache/*

# Zero out the free space to save space in the final image
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Clear history
history -c
