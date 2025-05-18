# Fedora Silverblue Setup Guide

> ⚠️ This guide is a work in progress.

## Overview

This guide walks you through setting up Fedora Silverblue with Ansible, Distrobox, and Nix.

______________________________________________________________________

## 1. Install Fedora Silverblue

Install Fedora Silverblue as you normally would.

______________________________________________________________________

## 2. Update the System

```shell
[HOST] $ rpm-ostree update
```

> 🔁 Reboot after updating.

______________________________________________________________________

## 3. Install Required Packages

Install Ansible and `python3-psutil`:

```shell
[HOST] $ rpm-ostree install ansible python3-psutil
```

______________________________________________________________________

## 4. Set Hostname

```shell
[HOST] $ hostnamectl hostname silverblue
```

> 🔁 Reboot after setting the hostname to make new rpm-ostree commit active.

______________________________________________________________________

## 5. Configure the Host

Clone your configuration repository and apply the host playbook:

```shell
[HOST] $ git clone https://github.com/trin94/nix-config.git ~/.dotfiles
[HOST] $ cd ~/.dotfiles/gnome-ansible/
[HOST] $ ./run-host-playbook.sh
```

______________________________________________________________________

## 6. Prepare Directory for Nix Store

```shell
[HOST] $ sudo mkdir -p /var/home/nix-store/store
[HOST] $ sudo mkdir -p /var/home/nix-store/var/nix/db
[HOST] $ sudo chown -R "$USER:$USER" /var/home/nix-store
```

______________________________________________________________________

## 7. Install Distrobox

Install Distrobox via alternative method:

```shell
[HOST] $ curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
```

______________________________________________________________________

## 8. Create `nix-box` Container

```shell
[HOST] $ distrobox create \
  --name nix-box \
  --image registry.fedoraproject.org/fedora:latest \
  --volume /var/home/nix-store:/nix \
  --init --yes
```

______________________________________________________________________

## 9. Enter `nix-box`

```shell
[HOST] $ distrobox enter nix-box
```

______________________________________________________________________

## 10. Install and Activate Nix

```shell
[NIX-BOX] $ sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon
[NIX-BOX] $ . /var/home/elias/.nix-profile/etc/profile.d/nix.sh
```

______________________________________________________________________

## 11. Setup Home Manager

```shell
[NIX-BOX] $ nix-shell -p git just home-manager nh
[NIX-BOX@nix-shell] $ export NIX_CONFIG="experimental-features = nix-command flakes"
[NIX-BOX@nix-shell] $ just container-update
```

______________________________________________________________________

## 12. Create `fedora-box` Container

```shell
[HOST] $ distrobox create \
  --name fedora-box \
  --image registry.fedoraproject.org/fedora:latest \
  --volume /var/home/nix-store:/nix:ro \
  --init --yes
```

______________________________________________________________________

## 13. Enter `fedora-box`

```shell
[HOST] $ distrobox enter fedora-box
```

______________________________________________________________________

## 14. Enable Nix in `fedora-box`

```shell
[FEDORA-BOX] $ export PATH="$HOME/.nix-profile/bin:$PATH"

# Optional: Add to shell profile for persistence
# if [ -d "$HOME/.nix-profile/bin" ]; then
#   export PATH="$HOME/.nix-profile/bin:$PATH"
# fi
```

______________________________________________________________________
