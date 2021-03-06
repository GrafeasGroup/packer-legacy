#!/usr/bin/env bash
set -euo pipefail

rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*

for directory in /var /etc /lib /lib64 /opt /usr /var; do
  # Remove cache entries
  find "$directory" -name 'cache' -print0 | xargs -0 -I{} rm -rf {}/*
  # Remove backups from dpkg installs (it's a container... with layers... we have backups)
  find "$directory" -type f \( -name '*-old' -or -name '*.old' \) -delete
  # Remove python cache files
  find "$directory" \( \( -type d -name '__pycache__' \) -or \( -name '*.pyc' -type f \) \) -print0 | xargs -0 -I{} rm -rf {}
done

find /var/log -type f \( -name '*.log' -or -name '*.syslog' \) -delete

logs=(
  /var/log/cron
  /var/log/dmesg
  /var/log/lastlog
  /var/log/maillog
  /var/log/messages
  /var/log/secure
  /var/log/wtmp
  /var/log/audit/audit.log
)
for log in "${logs[@]}"; do
  if [ -e "$log" ]; then true >"$log"; fi
done

for directory in /root /home; do
  find "$directory" -maxdepth 1 -mindepth 1 -type f -name '.python_history' -delete
  find "$directory" -maxdepth 1 -mindepth 1 -type d -name '.cache' -print0 | xargs -0 -I{} rm -rf {}
  find "$directory" -maxdepth 1 -mindepth 1 -type d -name '.pki' -print0 | xargs -0 -I{} rm -rf {}
  find "$directory" -maxdepth 1 -mindepth 1 -type d -name '~*' -print0 | xargs -0 -I{} rm -rf {}
  if [ -e "${directory}/.ssh/known_hosts" ]; then
    rm -rf "${directory}/.ssh/known_hosts"
  fi
done

# Clean up /root
root_user_logs=(
  /root/anaconda-ks.cfg
  /root/install.log
  /root/install.log.syslog
)

for item in "${root_user_logs[@]}"; do
  if [ -e "$item" ]; then
    rm -rf "$item"
  fi
done

# Find and remove any artifacts from packer ssh proxy
find / -maxdepth 1 -mindepth 1 -name '~*' -print0 | xargs -0 -I{} rm -rf {}

# Clear history
history -c
