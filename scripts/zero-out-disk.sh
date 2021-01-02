#!/usr/bin/env bash
set -euo pipefail

# Zero out the free space to save space in the final image
dd if=/dev/zero of=/EMPTY bs=1M 2>&1 || true
rm -f /EMPTY

history -c
