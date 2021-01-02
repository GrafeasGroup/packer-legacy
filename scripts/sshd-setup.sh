#!/usr/bin/env bash
set -euo pipefail

printf '>>>  %s\n' "Generating placeholder ssh keys for first boot. Please change them after deploying to production."
for key_type in rsa dsa ecdsa; do
  ssh-keygen -t "${key_type}" -f /etc/ssh/ssh_host_"${key_type}"_key -N ''
done
