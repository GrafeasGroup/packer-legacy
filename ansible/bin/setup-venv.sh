#!/usr/bin/env bash
set -euo pipefail

# Base directory of the git repo, relative to this script
BASE_DIR="${BASH_SOURCE[0]%/*}/.."

if [ ! -e "${BASE_DIR}/venv" ]; then
  python3 -m venv "${BASE_DIR}/venv"
fi

# Activate venv, but it might exit even if successful unless
# we temporarily reverse the `set -e` from earlier:
set +e
. "${BASE_DIR}/venv/bin/activate"
set -e

# python3 -m pip install --upgrade pip
python3 -m pip install pip-tools
hash -r
pip-sync "${BASE_DIR}/requirements.txt"
# python3 -m pip install -r "${BASE_DIR}/ansible/requirements.txt"
hash -r

export ANSIBLE_FORCE_COLOR=1
export PYTHONUNBUFFERED=1

# MacOS + Ansible = >_<;;; , without this line:
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY='YES'
