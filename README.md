# Fedora + home-manager configuration

This repo contains my work-in-progress fedora and home-manager configuration.

## Setup

```shell
nix-shell -p git just home-manager nh nixfmt treefmt2

git clone https://github.com/trin94/nix-config.git ~/.dotfiles
cd ~/.dotfiles

export NIX_CONFIG="experimental-features = nix-command flakes"

just update
```

# Misc

- `nix flake update --commit-lock-file`
- https://www.zknotes.com/page/alternate-nixpkgs-in-flakes-nixos
- https://github.com/EmergentMind/nix-config
