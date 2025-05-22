# Fedora (Workstation / Silverblue) with Home Manager Configuration

This repository includes my current Fedora setup along with a work-in-progress Home Manager configuration.

## Installation

```shell
nix-shell -p git just home-manager nh

git clone https://github.com/trin94/nix-config.git ~/.dotfiles
cd ~/.dotfiles
just update
```

## Additional Notes

To update flake inputs and commit the new lock file:

```shell
nix flake update --commit-lock-file
```
