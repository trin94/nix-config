#!/usr/bin/env just --justfile

set dotenv-load := true

export NIX_CONFIG := 'experimental-features = nix-command flakes'

USER := env_var("USER")
HOSTNAME := `cat /etc/hostname`

alias fmt := format

@_default:
    just --list

# Format source
@format:
    # nix run github:nushell/nufmt .
    uvx prek --config .config/prek.toml run --all-files

[group('dev')]
update-git-hook-dependencies:
    uvx prek --config .config/prek.toml auto-update

# Build home to 'result' directory
[group('run')]
verify: format
    nh home build --out-link result --configuration "{{ USER }}@{{ HOSTNAME }}" .

# Apply home configuration
[group('run')]
apply: format
    # home-manager switch --flake ".#{{ USER }}@{{ HOSTNAME }}"
    nh home switch --configuration "{{ USER }}@{{ HOSTNAME }}" .

# Update then apply home configuration
[group('run')]
update:
    nh home switch --update --configuration "{{ USER }}@{{ HOSTNAME }}" .

# Add a new program, needs to be enabled manually
[group('configure')]
add-program NAME:
    cat setups/programs/_template | sed 's/@@NAME@@/{{ NAME }}/g' > setups/programs/{{ NAME }}.nix
    just format

# Build system to 'result' directory
[group('run')]
os-verify: format
    nh os build --out-link result --hostname "{{ HOSTNAME }}" .

# Apply system configuration
[group('run')]
os-apply: format
    nh os switch --hostname "{{ HOSTNAME }}" .

# Update then apply system configuration
[group('run')]
os-update:
    nh os switch --update --hostname "{{ HOSTNAME }}" .
