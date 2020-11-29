#!/usr/bin/env bash
set -euo pipefail

source "${BASH_SOURCE[0]%/*}/setup-venv.sh"

ansible-galaxy "$@"
