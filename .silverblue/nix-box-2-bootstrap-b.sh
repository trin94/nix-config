#!/usr/bin/env bash

# Executed inside the distrobox
echo -e "\e[34mBootstrapping nix-box (2/3)...\e[0m"

# Check if Nix is already installed
if [ ! -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  echo -e "\e[34mInstalling Nix package manager...\e[0m"
  curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install | sh -s -- --no-daemon
else
  echo -e "\e[34mNix is already installed. Skipping installation.\e[0m"
fi

# Load Nix environment
. "$HOME/.nix-profile/etc/profile.d/nix.sh"

# Run the nix-shell bootstrap script
nix-shell -p git just home-manager nh --run "$(dirname "$0")/nix-box-2-bootstrap-c.sh"
