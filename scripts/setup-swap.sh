#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC2223
: ${SWAP_FILE:=/provisioning_swap_file}

if command -v fallocate &>/dev/null; then
  fallocate -l 3G "${SWAP_FILE}"
else
  dd if=/dev/zero of="${SWAP_FILE}" bs=1024 count="$(( 1048576 * 3 ))"
fi
chmod 600 "${SWAP_FILE}"

mkswap "${SWAP_FILE}"
swapon "${SWAP_FILE}"
