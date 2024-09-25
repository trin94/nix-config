#!/usr/bin/env just --justfile

_list:
    @just --list

# Build current configuration into directory 'result'
verify:
    home-manager build --flake .

# Apply current configuration
apply:
    home-manager switch --flake .

# Format source
format:
    @nixfmt .
