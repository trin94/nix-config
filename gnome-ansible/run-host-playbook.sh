#!/usr/bin/env bash

echo "Will run ansible playbook for host: $HOSTNAME"

read -rp "Do you want to continue? [Y/n] " answer
answer=${answer:-y}  # Default to 'y' if empty

if [[ "$answer" != "y" ]]; then
  echo "Aborted."
  exit 1
fi

set -euxo pipefail

ansible-playbook --ask-become-pass --verbose --inventory-file hosts.ini --limit "$HOSTNAME" playbook_base.yml
