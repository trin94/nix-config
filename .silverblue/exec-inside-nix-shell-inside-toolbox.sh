#!/usr/bin/env bash

set -euo pipefail

# Executed in the toolbox within a nix-shell

echo -e "\e[34mBuilding home-manager configuration...\e[0m"
cd "$HOME/.dotfiles" || exit 1
just update
