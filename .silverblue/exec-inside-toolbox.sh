#!/usr/bin/env bash

set -euo pipefail

# Executed inside the toolbox

echo -e "\e[34mInstalling packages...\e[0m"
sudo dnf install -yq ansible python3-pip libXrender libXtst libXi freetype libXrandr libXext libXfixes libX11 libXau libxcb libXdmcp gtk3 > /dev/null

echo "elias ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/99-toolbox-passwordless
sudo chmod 0440 /etc/sudoers.d/99-toolbox-passwordless


cd "$HOME/.dotfiles/"

echo -e "\e[34mConfiguring toolbox...\e[0m"
ANSBILE_PLAYBOOKS="$HOME/.dotfiles/gnome-ansible/"
cd "$ANSBILE_PLAYBOOKS" || exit 1
./run-host-playbook.sh --non-interactive --hostname toolbx --no-ask-become-pass


cd "$HOME/.dotfiles/"

echo -e "\e[34mInstalling nix package manager...\e[0m"
if [ ! -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  echo -e " > \e[34mInstalling Nix package manager...\e[0m"
  curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install | sh -s -- --no-daemon
  echo -e " > \e[34mInstalling Nix package manager... Done!\e[0m"
else
  echo -e " > \e[34m Nix is already installed. Skipping installation.\e[0m"
fi


# Load Nix environment
. "$HOME/.nix-profile/etc/profile.d/nix.sh"

# Run the nix-shell bootstrap script
nix-shell -p git just home-manager nh --run "$HOME/.dotfiles/.silverblue/exec-inside-nix-shell-inside-toolbox.sh"
