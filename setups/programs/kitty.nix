{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myOS.programs.kitty;
in
{

  options.myOS.programs.kitty = with lib; {

    enable = mkEnableOption "kitty";

    configure = mkOption {
      type = types.nullOr types.bool;
      default = cfg.enable;
    };

  };

  config = lib.mkIf cfg.configure {

    xdg.configFile."kitty/kitty.conf".text = ''
      cursor_blink_interval 0.5
      cursor_shape beam
      copy_on_select clipboard
      shell fish
      window_padding_width 5
      initial_window_width 120c
      initial_window_height 30c
      font_family CaskaydiaCove NF
      bold_font CaskaydiaCove NF Bold
      italic_font CaskaydiaCove NF Italic
      bold_italic_font CaskaydiaCove NF Bold Italic
      font_size 14
      font_size 14
      sync_to_monitor yes
      wayland_titlebar_color system
      linux_display_server wayland
    '';

  };

}
