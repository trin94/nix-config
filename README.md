# nixOS config

This repo contains my work-in-progress nixOS and home-manager configuration.

## Install on new machine

```shell
nix-shell -p git just home-manager nh nixfmt

git clone https://github.com/trin94/nix-config.git ~/.dotfiles
cd ~/.dotfiles

# Configure new setup
cp /etc/nixos/hardware-configuration.nix setups/<hostname>.hardware.nix
cp /etc/nixos/configuration.nix setups/<hostname>.system.nix
touch <hostname>.user.nix

export NIX_CONFIG="experimental-features = nix-command flakes"

# nix flake update --commit-lock-file

just apply-system apply-user
```

## Flatpak

```shell
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

# Links

- https://www.zknotes.com/page/alternate-nixpkgs-in-flakes-nixos
- https://github.com/EmergentMind/nix-config
