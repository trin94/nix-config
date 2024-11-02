{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.myOS.desktop.hyprland;
  disabled = [ "" ];
in
{

  options.myOS.desktop.hyprland = with lib; {

    configure = mkEnableOption "hyprland";

    terminalApp = mkOption {
      type = types.str;
    };

    wallpaper = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    wallpaperDark = mkOption {
      type = types.nullOr types.str;
      default = cfg.wallpaper;
    };

  };

  config = lib.mkIf cfg.configure {

    wayland.windowManager.hyprland = {
      enable = true;

      xwayland.enable = true;
      systemd.enable = true;

      settings = {
        "$mod" = "SUPER";
        "$terminal" = "alacritty";
        "$fileManager" = "nautilus";

        env = [
          "XCURSOR_SIZE, 24"
          "NIXOS_OZONE_WL, 1"
        ];

      };

    };

  };

}
