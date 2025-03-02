#!/usr/bin/env just --justfile

set dotenv-load := true

USER := env_var("USER")
HOSTNAME := `cat /etc/hostname`
ADDITIONAL_ARGS := if HOSTNAME == "p16gen2" { "--impure" } else { "" }

_default:
    @just --list

# Build home to 'result' directory
[group('user')]
verify: format
    nh home build --out-link result --configuration "{{ USER }}@{{ HOSTNAME }}" . -- {{ ADDITIONAL_ARGS }}

# Apply home configuration
[group('user')]
apply: format
    nh home switch --configuration "{{ USER }}@{{ HOSTNAME }}" . -- {{ ADDITIONAL_ARGS }}

# Update then apply home configuration
[group('user')]
update: format
    nh home switch --update --configuration "{{ USER }}@{{ HOSTNAME }}" . -- {{ ADDITIONAL_ARGS }}

# Format source
format:
    @treefmt --config-file config/treefmt.toml --tree-root .

# Add a new program which needs to be enabled manually, though
[group('scripts')]
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
