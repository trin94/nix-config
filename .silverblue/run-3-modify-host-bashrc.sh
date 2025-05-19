#!/usr/bin/env bash

# This script will append a special section to the end of the host's .bashrc file
# that will configure the shell differently depending on it's running on the host or in a *-box container

BASHRC="$HOME/.bashrc"
START_TAG="# >>> CUSTOM BASH BLOCK START >>>"
END_TAG="# <<< CUSTOM BASH BLOCK END <<<"

CUSTOM_CONTENT=$(cat <<'EOF'
# >>> CUSTOM BASH BLOCK START >>>
# Conditional configuration based on hostname
if [[ "$(hostname)" == *-box ]]; then
  # Add Nix profile to PATH if present
  if [ -d "$HOME/.nix-profile/bin" ]; then
    export PATH="$HOME/.nix-profile/bin:$PATH"
  fi

  # Start fish shell only in interactive, non-fish shells
  if [[ $- == *i* ]] && command -v fish >/dev/null && [[ "$SHELL" != *fish ]]; then
    exec fish
  fi
else
  # Special configuration for the host
  alias box-fedora='distrobox enter fedora-box'
  alias box-nix='distrobox enter nix-box'
fi
# <<< CUSTOM BASH BLOCK END <<<
EOF
)

# Remove old block if it exists
if grep -q "$START_TAG" "$BASHRC"; then
    sed -i "/$START_TAG/,/$END_TAG/d" "$BASHRC"
fi

# Append new block at the end
echo "$CUSTOM_CONTENT" >> "$BASHRC"

echo ".bashrc has been updated."
