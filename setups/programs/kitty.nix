{
  config,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.kitty;
  fontConfig =
    if cfg.useMonoLisaFont then ''
      font_family      MonoLisa Variable
      bold_font        auto
      italic_font      auto
      bold_italic_font auto
      font_size 14
    '' else ''
      font_family CaskaydiaCove NF
      bold_font CaskaydiaCove NF Bold
      italic_font CaskaydiaCove NF Italic
      bold_italic_font CaskaydiaCove NF Bold Italic
      font_size 14
    '';
in
{

  options.myOS.programs.kitty = with lib; {

    enable = mkEnableOption "kitty";

    configure = mkOption {
      type = types.nullOr types.bool;
      default = cfg.enable;
    };

    enableCsd = mkOption {
      type = types.bool;
      default = true;
      description = "Enable client-side decorations";
    };

    useMonoLisaFont = mkOption {
      type = types.bool;
      default = false;
      description = "Use MonoLisa Variable font";
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
      ${fontConfig}
      sync_to_monitor yes
      linux_display_server wayland
      ${if cfg.enableCsd then "wayland_titlebar_color system" else "hide_window_decorations yes"}
      map ctrl+f no_op
      map ctrl+r no_op
      map ctrl+shift+f no_op
      map ctrl+shift+r no_op
      map ctrl+shift+n no_op
    '';
  };

}
