#!/usr/bin/env bash

set -euo pipefail

# Default values
target_host="${HOSTNAME:-}"
interactive=true
ask_become_pass=true

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --hostname)
      shift
      target_host="$1"
      ;;
    --non-interactive)
      interactive=false
      ;;
    --ask-become-pass)
      ask_become_pass=true
      ;;
    --no-ask-become-pass)
      ask_become_pass=false
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
  shift
done

# Ensure hostname is set
if [[ -z "$target_host" ]]; then
  echo "Error: No hostname provided and \$HOSTNAME is not set."
  exit 1
fi

echo "Will run ansible playbook for host: $target_host"

# Prompt unless non-interactive
if [[ "$interactive" == true ]]; then
  read -rp "Do you want to continue? [Y/n] " answer
  answer=${answer:-y}
  if [[ "$answer" != "y" ]]; then
    echo "Aborted."
    exit 1
  fi
fi

set -x  # Enable command tracing for ansible call

# Build ansible-playbook command dynamically
ansible_cmd=(
  ansible-playbook
  --inventory-file hosts.ini
  --limit "$target_host"
)

if [[ "$ask_become_pass" == true ]]; then
  ansible_cmd+=(--ask-become-pass)
fi

ansible_cmd+=(playbook_base.yml)

# Run the command
"${ansible_cmd[@]}"
