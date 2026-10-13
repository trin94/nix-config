fruppiOS Setup
==============

Steps
-----

1. Install fruppiOS
   - Follow the quickstart: https://github.com/trin94/fruppiOS#quickstart

2. Set the Hostname
   - sudo hostnamectl hostname <hostname>

3. Apply home-manager-configuration manually
   - nix shell nixpkgs#git nixpkgs#just nixpkgs#home-manager nixpkgs#nh
   - git clone https://github.com/trin94/nix-config.git ~/.dotfiles
   - cd ~/.dotfiles
   - just update

Troubleshooting
===============

If flake inputs are out of date or broken, try updating them manually:

   nix flake update --commit-lock-file
