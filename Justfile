#!/usr/bin/env just --justfile

_default:
    @just --list

# Build home to 'result' directory
[group('user')]
verify-user:
    nh home build --out-link result .

# Apply home configuration
[group('user')]
apply-user:
	nh home switch .

# Build system to 'result' directory
[group('system')]
verify-system:
    nh os build --out-link result --hostname nixos .

# Apply system configuration
[group('system')]
apply-system:
    nh os switch --hostname nixos .

# Format source
format:
    @nixfmt .
