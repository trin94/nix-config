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
# On HOST
rpm-ostree update
```

> 🔁 Reboot after updating.

______________________________________________________________________

## 3. Install Required Packages

Install Ansible and `python3-psutil`:

```shell
# On HOST
rpm-ostree install ansible python3-psutil
```

______________________________________________________________________

## 4. Set Hostname

```shell
# On HOST
hostnamectl hostname silverblue
```

> 🔁 Reboot after setting the hostname to make new rpm-ostree commit active.

______________________________________________________________________

## 5. Configure the Host

Clone your configuration repository and apply the host playbook:

```shell
# On HOST
git clone https://github.com/trin94/nix-config.git ~/.dotfiles
cd ~/.dotfiles/gnome-ansible/
./run-host-playbook.sh
```

______________________________________________________________________

## 6. Prepare Directory for Nix Store

```shell
# On HOST
sudo mkdir -p /var/home/nix-store/store
sudo mkdir -p /var/home/nix-store/var/nix/db
sudo chown -R "$USER:$USER" /var/home/nix-store
```

______________________________________________________________________

## 7. Install Distrobox

Install Distrobox via alternative method:

```shell
# On HOST
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
```

______________________________________________________________________

## 8. Boostrap `nix-box` Container

```shell
# On HOST
./run-1-1-nix-box-assemble.sh     # Recreates the nix-box container
./run-1-2-nix-box-bootstrap-a.sh  # Enters nix-box and installs home-manager config
```

______________________________________________________________________

## 9. Boostrap `fedora-box` Container

````shell
```shell
# On HOST
./run-2-1-fedora-box-assemble.sh     # Recreates the fedora-box container
./run-2-2-fedora-box-bootstrap-a.sh  # Enters fedora-box and runs ansible setup for container
````

______________________________________________________________________

## 10. Update HOST's .bashrc `fedora-box`

````shell
```shell
# On HOST
./run-3-modify-host-bashrc.sh  # Modifies the .bashrc with wire things together
````
