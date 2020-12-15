#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC2223
: ${SWAP_FILE:=/provisioning_swap_file}

swapoff "${SWAP_FILE}"
rm -rf "${SWAP_FILE}"
