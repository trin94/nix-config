{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.graphical.kitty;
in
{

  options.myOS.graphical.kitty = with lib; {

    enable = mkEnableOption "kitty";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      kitty
    ];

    programs.kitty = {
      enable = true;

      settings = {
        cursor_shape = "beam";
        copy_on_select = "clipboard";

        enable_audio_bell = false;

        shell = "fish";
        editor = "nvim";

        wayland_titlebar_color = "system";
        linux_display_server = "wayland";

        window_border_width = 0;
        draw_minimal_borders = "yes";

        window_padding_width = 5;

        confirm_os_window_close = 0;
        dynamic_background_opacity = false;
      };

    };

  };

}
