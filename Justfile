#!/usr/bin/env just --justfile

set dotenv-load

USER := env_var("USER")
HOSTNAME := `cat /etc/hostname`

ADDITIONAL_ARGS := if HOSTNAME == "p16gen2" { "--impure" } else { "" }

_default:
    @just --list

# Build home to 'result' directory
[group('user')]
verify-user: format
    nh home build --out-link result --configuration "{{ USER }}@{{ HOSTNAME }}" . -- {{ ADDITIONAL_ARGS }}

# Apply home configuration
[group('user')]
apply-user: format
    nh home switch --configuration "{{ USER }}@{{ HOSTNAME }}" . -- {{ ADDITIONAL_ARGS }}

# Update then apply home configuration
[group('user')]
update-user: format
    nh home switch --update --configuration "{{ USER }}@{{ HOSTNAME }}" . -- {{ ADDITIONAL_ARGS }}

# Build system to 'result' directory
[group('system')]
verify-system: format
    nh os build --out-link result --hostname {{ HOSTNAME }} .

# Apply system configuration
[group('system')]
apply-system: format
    nh os switch --hostname {{ HOSTNAME }} .

# Update then apply system configuration
[group('system')]
update-system: format
    nh os switch --update --hostname {{ HOSTNAME }} .

# Format source
format:
    @nixfmt .

# Add a new program which needs to be enabled manually, though
[group('scripts')]
add-program NAME TYPE="terminal":
    #!/usr/bin/env bash
    TYPE="{{ TYPE }}"

    cat > common/programs/{{ NAME }}.nix << EOF
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myOS.$TYPE.{{ NAME }};
    in
    {

      options.myOS.$TYPE.{{ NAME }} = with lib; {

        enable = mkEnableOption "{{ NAME }}";

      };

      config = lib.mkIf cfg.enable {

        home.packages = with pkgs; [
          {{ NAME }}
        ];

      };

    }
    EOF
    just format
