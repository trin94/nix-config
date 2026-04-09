Fedora Workstation Setup
========================

Steps
-----

1. Install Fedora Workstation
   - Perform a standard installation.

2. Update the System
   - sudo dnf update -y

3. Install Required Packages
   - sudo dnf install ansible python3-psutil

4. Set the Hostname
   - sudo hostnamectl hostname <hostname>

5. Apply Host Configuration
   - git clone https://github.com/trin94/nix-config.git ~/.dotfiles
   - cd ~/.dotfiles/ansible/
   - ./run-host-playbook.sh

6. Install nix package manager

7. Apply home-manager-configuration manually
   - nix-shell -p git just home-manager nh
   - git clone https://github.com/trin94/nix-config.git ~/.dotfiles
   - cd ~/.dotfiles
   - just update


Troubleshooting
===============

If flake inputs are out of date or broken, try updating them manually:

   nix flake update --commit-lock-file
