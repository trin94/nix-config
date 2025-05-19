#!/usr/bin/env bash

set -euo pipefail

# Default values
target_host="${HOSTNAME:-}"
interactive=true

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

ansible-playbook \
  --verbose \
  --ask-become-pass \
  --inventory-file hosts.ini \
  --limit "$target_host" \
  playbook_base.yml
