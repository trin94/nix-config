{
  config,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.niri;
in
{

  options.myOS.programs.niri = with lib; {

    enable = mkEnableOption "niri";

    portalBackend = mkOption {
      type = types.str;
      default = "gnome";
      description = "xdg-desktop-portal backend to prefer under niri";
    };

  };

  config = lib.mkIf cfg.enable {

    xdg.configFile."xdg-desktop-portal/niri-portals.conf".text = ''
      [preferred]
      default=${cfg.portalBackend}
      org.freedesktop.impl.portal.Screencast=${cfg.portalBackend}
      org.freedesktop.impl.portal.ScreenShot=${cfg.portalBackend}
    '';

  };

}
