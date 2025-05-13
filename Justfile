#!/usr/bin/env just --justfile

set dotenv-load := true

USER := env_var("USER")
HOSTNAME := `cat /etc/hostname`
ADDITIONAL_ARGS := if HOSTNAME == "p16gen2" { "--impure" } else { "" }

@_default:
    just --list

# Format source
@format:
    #pre-commit run --all-files

# Build home to 'result' directory
[group('run')]
verify: format
    nh home build --out-link result --configuration "{{ USER }}@{{ HOSTNAME }}" . -- {{ ADDITIONAL_ARGS }}

# Apply home configuration
[group('run')]
apply: format
    nh home switch --configuration "{{ USER }}@{{ HOSTNAME }}" . -- {{ ADDITIONAL_ARGS }}

# Update then apply home configuration
[group('run')]
update:
    nh home switch --update --configuration "{{ USER }}@{{ HOSTNAME }}" . -- {{ ADDITIONAL_ARGS }}

# Add a new program, needs to be enabled manually
[group('configure')]
add-program NAME:
    cat common/programs/_template | sed 's/@@NAME@@/{{NAME}}/g' > common/programs/{{NAME}}.nix
    just format

[group('silverblue')]
silverblue-update:
    nh home switch --update --configuration "elias@silverblue" .

[group('silverblue')]
silverblue-verify: format
    nh home build --out-link result --configuration "elias@silverblue" .

[group('silverblue')]
silverblue-apply: format
    nh home switch --configuration "elias@silverblue" .
