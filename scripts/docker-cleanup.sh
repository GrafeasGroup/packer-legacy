#!/usr/bin/env bash
set -euo pipefail

rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*

for directory in /var /etc /lib /lib64 /opt /usr /var; do
  # Remove cache entries
  find "$directory" -name 'cache' -print0 | xargs -0 -I{} rm -rf {}/*
  # Remove backups from dpkg installs (it's a container... with layers... we have backups)
  find "$directory" -type f -name '-old' -delete
  # Remove python cache files
  find "$directory" \( \( -type d -name '__pycache__' \) -or \( -name '*.pyc' -type f \) \) -print0 | xargs -0 -I{} rm -rf {}
done

find /var/log -type f -name '*log' -print0 | xargs -0 -I{} bash -c '>{}'

for directory in /root /home; do
  find "$directory" -type f -name '.python_history' -delete
  find "$directory" -type d -name '.cache' -print0 | xargs -0 -I{} rm -rf {}
done

# Find and remove any artifacts from packer ssh proxy
find / -maxdepth 1 -mindepth 1 -name '~*' -print0 | xargs -0 -I{} rm -rf {}
