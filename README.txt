Fedora Setup with Home Manager
==============================

This is my current setup for Fedora Workstation and Silverblue.
It uses Home Manager for dotfile management and is a work in progress.

Installation
------------

Run the following:

nix-shell -p git just home-manager nh
git clone https://github.com/trin94/nix-config.git ~/.dotfiles
cd ~/.dotfiles
just update

Troubleshooting
---------------

If flake inputs are out of date or broken, try updating them manually:

nix flake update --commit-lock-file
