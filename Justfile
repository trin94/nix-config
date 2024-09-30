#!/usr/bin/env just --justfile

_default:
    @just --list

# Build home to 'result' directory
[group('user')]
verify-user:
    nh home build --out-link result --update .

# Apply home configuration
[group('user')]
apply-user:
	nh home switch --update .

# Build system to 'result' directory
[group('system')]
verify-system:
    nh os build --out-link result --update --hostname nixos .

# Apply system configuration
[group('system')]
apply-system:
    nh os switch --update --hostname nixos .

# Format source
format:
    @nixfmt .
