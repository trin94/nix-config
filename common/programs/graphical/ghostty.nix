{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.graphical.ghostty;
in
{

  options.myOS.graphical.ghostty = with lib; {

    enable = mkEnableOption "ghostty";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      ghostty
    ];

    programs.ghostty = {
      enable = true;

      settings = {
        auto-update = "off";

        bold-is-bright = true;

        command = "${lib.getExe pkgs.fish} --login --interactive";

        confirm-close-surface = false;

        copy-on-select = true;

        cursor-style = "";

        gtk-tabs-location = "hidden";

        quit-after-last-window-closed = true;

        window-height = 30;
        window-padding-x = 5;
        window-padding-y = 5;
        window-width = 120;
      };

    };

  };

}
