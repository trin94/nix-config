#!/usr/bin/env bash

set -euo pipefail

target_host="${HOSTNAME:?Error: \$HOSTNAME is not set.}"

echo "Will run ansible playbook for host: $target_host"
read -rp "Do you want to continue? [Y/n] " answer
if [[ "${answer:-y}" != "y" ]]; then
  echo "Aborted."
  exit 1
fi

set -x
ansible-playbook --limit "$target_host" --ask-become-pass playbook_base.yml
