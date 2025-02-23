{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.graphical.zed;
in
{

  options.myOS.graphical.zed = with lib; {

    enable = mkEnableOption "zed";

    configure = mkOption {
      type = types.nullOr types.bool;
      default = cfg.enable;
    };

  };

  config = {

    home.packages = lib.mkIf cfg.enable (
      with pkgs;
      [
        zed-editor
      ]
    );

    programs.zed-editor.enable = lib.mkIf cfg.enable true;

    home.file = lib.mkIf cfg.configure {

      ".config/zed/settings.json".text = builtins.toJSON {

        auto_install_extensions = {
          "dockerfile" = true;
          "fish" = true;
          "git-firefly" = true;
          "ini" = true;
          "jinja2" = true;
          "just" = true;
          "nix" = true;
          "nu" = true;
          "qml" = true;
          "ruff" = true;
          "toml" = true;
        };

        autosave = {
          after_delay = {
            "milliseconds" = 1000;
          };
        };

        base_keymap = "JetBrains";
        buffer_font_family = "JetBrains Mono NL";
        buffer_font_size = 20;

        git = {
          inline_blame = {
            enabled = false;
          };
        };

        languages = {
          Markdown = {
            remove_trailing_whitespace_on_save = false;
          };
        };

        projects_online_by_default = false;

        tab_bar = {
          show_nav_history_buttons = false;
        };

        tabs = {
          git_status = true;
        };

        theme = {
          mode = "dark";
          light = "One Light";
          dark = "One Dark";
        };

        ui_font_family = "Noto Sans";
        ui_font_size = 20;

      };

    };

  };

}
