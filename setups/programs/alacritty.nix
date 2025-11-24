{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myOS.programs.alacritty;
in
{

  options.myOS.programs.alacritty = with lib; {

    enable = mkEnableOption "alacritty";

    configure = mkOption {
      type = types.nullOr types.bool;
      default = cfg.enable;
    };

    shell = mkOption {
      type = types.str;
      default = "fish";
    };

    fontSize = mkOption {
      type = types.int;
      default = 14;
      description = "Font size";
    };

  };

  config = lib.mkIf cfg.configure {

    xdg.configFile."alacritty/alacritty.toml".text = ''
      [window]
      padding.x = 5
      padding.y = 5
      dimensions.columns = 120
      dimensions.lines = 30
      decorations = "Transparent"

      [font]
      size = ${toString cfg.fontSize}

      [font.normal]
      family = "CaskaydiaCove NF"
      style = "Regular"

      [font.bold]
      family = "CaskaydiaCove NF"
      style = "Bold"

      [font.italic]
      family = "CaskaydiaCove NF"
      style = "Italic"

      [font.bold_italic]
      family = "CaskaydiaCove NF"
      style = "Bold Italic"

      [cursor]
      style.shape = "Beam"
      style.blinking = "On"
      blink_interval = 500

      [selection]
      save_to_clipboard = true

      [[keyboard.bindings]]
      key = "Back"
      mods = "Command"
      chars = "\u0017"

      [terminal.shell]
      program = "${cfg.shell}"
    '';

  };

}
