#!/usr/bin/env bash

# Executed on the distro box within a nix-shell
echo -e "\e[34mBootstrapping nix-box (3/3)...\e[0m"

cd "$HOME/.dotfiles" || exit 1
echo -e "\e[34mBuilding home-manager configuration...\e[0m"
just update
