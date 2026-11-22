{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.umbriel;
  tomlFormat = pkgs.formats.toml { };
in
{

  options.myOS.programs.umbriel = with lib; {

    # The host image ships the compositor; this module only manages its configuration.
    enable = mkEnableOption "Umbriel configuration";

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      description = "Host-specific Umbriel settings, merged over the shared configuration.";
    };

  };

  config = lib.mkIf cfg.enable {

    xdg.configFile."umbriel/config.toml".source = tomlFormat.generate "umbriel-config.toml" (
      lib.recursiveUpdate (import ../umbriel/common.nix) cfg.settings
    );

  };

}
