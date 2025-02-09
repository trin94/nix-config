{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.stylix;
in
{

  options.myOS.stylix = with lib; {

    configure = mkEnableOption "stylix";

    wallpaper = mkOption {
      type = types.str;
    };

    # https://github.com/tinted-theming/schemes/tree/spec-0.11
    base16Scheme = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    dark-theme = mkOption {
      type = types.bool;
    };

  };

  config = lib.mkIf cfg.configure {

    stylix = {

      enable = true;
      autoEnable = false;

      targets = {
        alacritty.enable = true;
        bat.enable = true;
        fish.enable = true;
        fzf.enable = true;
        ghostty.enable = true;
        nushell.enable = true;
      };

      image = cfg.wallpaper;
      polarity = if cfg.dark-theme then "dark" else "light";

      base16Scheme =
        if (cfg.base16Scheme != null) then
          cfg.base16Scheme
        else
          "${pkgs.base16-schemes}/share/themes/nord.yaml";

      fonts = {

        serif = {
          package = pkgs.adwaita-fonts;
          name = "Adwaita Sans";
        };

        sansSerif = {
          package = pkgs.adwaita-fonts;
          name = "Adwaita Sans";
        };

        monospace = {
          package = pkgs.nerd-fonts.caskaydia-cove;
          name = "CaskaydiaCove NF";
        };

        sizes = {
          terminal = 15;
          applications = 11;
        };
      };

      cursor = {
        name = "Adwaita";
        size = 24;
      };

    };

  };

}
