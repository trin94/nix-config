# nixOS config

This repo contains my work-in-progress home-manager configuration.

## Install on new machine

```shell
nix-shell -p git just home-manager nh nixfmt treefmt2

git clone https://github.com/trin94/nix-config.git ~/.dotfiles
cd ~/.dotfiles

export NIX_CONFIG="experimental-features = nix-command flakes"

# nix flake update --commit-lock-file

just update
```

## Flatpak

```shell
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

# Links

- https://www.zknotes.com/page/alternate-nixpkgs-in-flakes-nixos
- https://github.com/EmergentMind/nix-config
