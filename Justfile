#!/usr/bin/env just --justfile

set dotenv-load := true

USER := env_var("USER")
HOSTNAME := `cat /etc/hostname`
ADDITIONAL_ARGS := if HOSTNAME == "p16gen2" { "--impure" } else { "" }

@_default:
    just --list

# Format source
@format:
    pre-commit run --all-files

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
update: format
    nh home switch --update --configuration "{{ USER }}@{{ HOSTNAME }}" . -- {{ ADDITIONAL_ARGS }}

# Add a new program, needs to be enabled manually
[group('configure')]
add-program NAME:
    #!/usr/bin/env bash

    cat > common/programs/{{ NAME }}.nix << EOF
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.myOS.programs.{{ NAME }};
    in
    {

      options.myOS.programs.{{ NAME }} = with lib; {

        enable = mkEnableOption "{{ NAME }}";

      };

      config = lib.mkIf cfg.enable {

        home.packages = with pkgs; [
          {{ NAME }}
        ];

        programs.{{ NAME }} = {
          enable = true;
        };

      };

    }
    EOF
    just format
