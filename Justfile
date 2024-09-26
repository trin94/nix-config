#!/usr/bin/env just --justfile

_list:
    @just --list

# Build home to 'result' directory
[group('user')]
verify-user:
    home-manager build --flake .

# Apply home configuration
[group('user')]
apply-user:
    home-manager switch --flake .

# Build system to 'result' directory
[group('system')]
verify-system:
    nixos-rebuild build --flake .#nixos

# Apply system configuration
[group('system')]
apply-system:
    sudo nixos-rebuild switch --flake .#nixos

# Format source
format:
    @nixfmt .
