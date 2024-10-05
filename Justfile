#!/usr/bin/env just --justfile

USER := env_var("USERNAME")
HOSTNAME := `cat /etc/hostname`

_default:
    @just --list

# Build home to 'result' directory
[group('user')]
verify-user:
    nh home build --out-link result --configuration "{{ USER }}@{{ HOSTNAME }}" .

# Apply home configuration
[group('user')]
apply-user:
    nh home switch --configuration "{{ USER }}@{{ HOSTNAME }}" .

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

# Add a new program which needs to be enabled manually, though
[group('scripts')]
add-program NAME:
    #!/usr/bin/env bash
    TYPE="graphical"

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
