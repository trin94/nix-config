Fedora Setup
============

This repository contains configuration scripts for setting up:

1. Fedora Silverblue
2. Fedora Workstation (traditional package-based setup)

The Silverblue setup includes host configuration via Ansible, toolbox setup,
toolbox setup via Ansible, and nix-based home-manager configuration
inside the toolbox.

The Workstation setup focuses on applying host-level Ansible configuration and
a nix-based home-manager setup directly on the system.

IMPORTANT: These scripts are intended for personal use. They contain hardcoded
paths, hostnames, and other user-specific values.

Note: Unless specified otherwise, all commands are to be run on the host system.


Fedora Silverblue + Home-Manager Setup
======================================

Steps
-----

1. Install Fedora Silverblue
   - Perform a standard installation.

2. Update the System
   - rpm-ostree update
   - reboot

3. Install Required Packages
   - rpm-ostree install ansible python3-psutil

4. Set the Hostname
   - hostnamectl hostname silverblue
   - reboot

5. Apply Host Configuration
   - git clone https://github.com/trin94/nix-config.git ~/.dotfiles
   - cd ~/.dotfiles/gnome-ansible/
   - ./run-host-playbook.sh

6. Bootstrap Toolbox
   - cd ~/.dotfiles/.silverblue
   - ./bootstrap-toolbox.sh

7. Update .bashrc on Host
   - cd ~/.dotfiles/.silverblue
   - ./update-host-bashrc.sh


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
   - cd ~/.dotfiles/gnome-ansible/
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
