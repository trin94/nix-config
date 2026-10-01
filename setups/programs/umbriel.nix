{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myOS.programs.umbriel;
  tomlFormat = pkgs.formats.toml { };
in
{
  imports = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ inputs.umbriel.homeModules.default ];

  options.myOS.programs.umbriel = with lib; {
    enable = mkEnableOption "Umbriel";

    configure = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Manage the Umbriel configuration independently of its package.";
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      description = ''
        Host-specific Umbriel settings merged with the shared configuration.
        HDR defaults to on for configured outputs; set an output's hdr to off
        to keep it in SDR.
      '';
    };
  };

  config = {
    assertions = [
      {
        assertion = !(cfg.enable || cfg.configure) || pkgs.stdenv.hostPlatform.isLinux;
        message = "myOS.programs.umbriel is only supported on Linux.";
      }
    ];
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    programs.umbriel = lib.mkIf (cfg.enable || cfg.configure) {
      enable = true;
      package =
        if cfg.enable then inputs.umbriel.packages.${pkgs.stdenv.hostPlatform.system}.default else null;
      settings =
        if cfg.configure then
          lib.mkMerge [
            (lib.mapAttrsRecursive (_: lib.mkDefault) (import ../umbriel/common.nix))
            {
              output = lib.mapAttrs (_: _: { hdr = lib.mkDefault "on"; }) (cfg.settings.output or { });
            }
            cfg.settings
          ]
        else
          null;
    };
  };
}
