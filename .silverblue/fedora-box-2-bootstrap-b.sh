#!/usr/bin/env bash

# Executed inside the distrobox
echo -e "\e[34mBootstrapping fedora-box (2/2)...\e[0m"

ANSBILE_PLAYBOOKS="$HOME/.dotfiles/gnome-ansible/"

cd "$ANSBILE_PLAYBOOKS" || exit 1

./run-host-playbook.sh --non-interactive --hostname "container-fedora-box"
