{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.zed;

  # Islands Dark theme definition
  islandsDarkTheme = {
    "$schema" = "https://zed.dev/schema/themes/v0.1.0.json";
    name = "Islands Dark";
    author = "Custom";
    themes = [
      {
        name = "Islands Dark";
        appearance = "dark";
        style = {
          background = "#1a1b1e";
          foreground = "#ced0d6";
          border = "#26272a";
          "border.variant" = "#2d2e31";
          "border.focused" = "#3a3b3f";
          "border.selected" = "#3a3b3f";
          "border.transparent" = "#00000000";
          "border.disabled" = "#26272a";
          "elevated_surface.background" = "#1d1e21";
          "surface.background" = "#131415";
          "element.background" = "#16171a";
          "element.hover" = "#1a1b1e";
          "element.active" = "#1d1e21";
          "element.selected" = "#1d1e21";
          "element.disabled" = "#131415";
          "drop_target.background" = "#1d1e21aa";
          "ghost_element.background" = "#00000000";
          "ghost_element.hover" = "#1a1b1e";
          "ghost_element.active" = "#1d1e21";
          "ghost_element.selected" = "#1d1e21";
          "ghost_element.disabled" = "#131415";
          text = "#ced0d6";
          "text.muted" = "#7a7e85";
          "text.placeholder" = "#5a5e65";
          "text.disabled" = "#5a5e65";
          "text.accent" = "#6b8ff9";
          icon = "#9a9da3";
          "icon.muted" = "#5a5e65";
          "icon.disabled" = "#3a3e45";
          "icon.placeholder" = "#5a5e65";
          "icon.accent" = "#6b8ff9";
          "status_bar.background" = "#16171a";
          "title_bar.background" = "#16171a";
          "title_bar.inactive_background" = "#16171a";
          "toolbar.background" = "#1d1e21";
          "tab_bar.background" = "#131415";
          "tab.inactive_background" = "#131415";
          "tab.active_background" = "#1a1b1e";
          "search.match_background" = "#3a4c50";
          "panel.background" = "#131415";
          "panel.focused_border" = "#3a3b3f";
          "pane.focused_border" = "#3a3b3f";
          "pane_group.border" = "#222326";
          "scrollbar.thumb.background" = "#3a3b3f4d";
          "scrollbar.thumb.hover_background" = "#4a4b4f66";
          "scrollbar.thumb.border" = "#00000000";
          "scrollbar.track.background" = "#131415";
          "scrollbar.track.border" = "#26272a";
          "editor.foreground" = "#ced0d6";
          "editor.background" = "#1a1b1e";
          "editor.gutter.background" = "#1a1b1e";
          "editor.subheader.background" = "#1d1e21";
          "editor.active_line.background" = "#21222580";
          "editor.highlighted_line.background" = "#212225";
          "editor.line_number" = "#4e5157";
          "editor.active_line_number" = "#b4b8bf";
          "editor.invisible" = "#2a2b2e";
          "editor.wrap_guide" = "#26272a";
          "editor.active_wrap_guide" = "#35363a";
          "editor.indent_guide" = "#26272a";
          "editor.indent_guide_active" = "#35363a";
          "editor.document_highlight.read_background" = "#35363a66";
          "editor.document_highlight.write_background" = "#4a6edb33";
          "editor.current_line.background" = "#21222580";
          "terminal.background" = "#131415";
          "terminal.foreground" = "#ced0d6";
          "terminal.bright_foreground" = "#e5e7eb";
          "terminal.dim_foreground" = "#868a91";
          "terminal.ansi.black" = "#131415";
          "terminal.ansi.bright_black" = "#4e5157";
          "terminal.ansi.red" = "#fa5762";
          "terminal.ansi.bright_red" = "#ff6b76";
          "terminal.ansi.green" = "#7ec482";
          "terminal.ansi.bright_green" = "#8ed696";
          "terminal.ansi.yellow" = "#debc7e";
          "terminal.ansi.bright_yellow" = "#f2c55c";
          "terminal.ansi.blue" = "#749ded";
          "terminal.ansi.bright_blue" = "#83acfc";
          "terminal.ansi.magenta" = "#b189f5";
          "terminal.ansi.bright_magenta" = "#bb8ef5";
          "terminal.ansi.cyan" = "#72cfd6";
          "terminal.ansi.bright_cyan" = "#82dfe6";
          "terminal.ansi.white" = "#ced0d6";
          "terminal.ansi.bright_white" = "#e5e7eb";
          "link_text.hover" = "#6b8ff9";
          conflict = "#d4b077";
          "conflict.background" = "#4a3f2a33";
          "conflict.border" = "#9a7f5066";
          created = "#6fa876";
          "created.background" = "#2a3d2c33";
          "created.border" = "#4a6d4e66";
          deleted = "#d67983";
          "deleted.background" = "#4a2e3133";
          "deleted.border" = "#7a5a5e66";
          error = "#d67983";
          "error.background" = "#3a252833";
          "error.border" = "#a5545a66";
          hidden = "#6f737a";
          "hidden.background" = "#1a1b1e";
          "hidden.border" = "#26272a";
          hint = "#6f737a";
          "hint.background" = "#1d1e2133";
          "hint.border" = "#3a3b3f66";
          ignored = "#6f737a";
          "ignored.background" = "#1a1b1e";
          "ignored.border" = "#4e5157";
          info = "#6b8fc9";
          "info.background" = "#1f2a3d33";
          "info.border" = "#4a6a9566";
          modified = "#6b8fc9";
          "modified.background" = "#2a3a4d33";
          "modified.border" = "#4a6a9566";
          predictive = "#6f737a";
          "predictive.background" = "#35363a66";
          "predictive.border" = "#26272a";
          renamed = "#6b8fc9";
          "renamed.background" = "#1f2a3d33";
          "renamed.border" = "#4a6a9566";
          success = "#6fa876";
          "success.background" = "#2a3d2c33";
          "success.border" = "#4a6d4e66";
          unreachable = "#6f737a";
          "unreachable.background" = "#1a1b1e";
          "unreachable.border" = "#4e5157";
          warning = "#d4b077";
          "warning.background" = "#4a3f2a33";
          "warning.border" = "#9a7f5066";
          players = [
            {
              cursor = "#548af7";
              background = "#548af720";
              selection = "#548af730";
            }
            {
              cursor = "#7ec482";
              background = "#7ec48220";
              selection = "#7ec48230";
            }
            {
              cursor = "#f2c55c";
              background = "#f2c55c20";
              selection = "#f2c55c30";
            }
            {
              cursor = "#b189f5";
              background = "#b189f520";
              selection = "#b189f530";
            }
            {
              cursor = "#fa5762";
              background = "#fa576220";
              selection = "#fa576230";
            }
            {
              cursor = "#72cfd6";
              background = "#72cfd620";
              selection = "#72cfd630";
            }
            {
              cursor = "#debc7e";
              background = "#debc7e20";
              selection = "#debc7e30";
            }
            {
              cursor = "#d981de";
              background = "#d981de20";
              selection = "#d981de30";
            }
          ];
          syntax = {
            attribute = {
              color = "#b189f5";
              font_style = null;
              font_weight = null;
            };
            boolean = {
              color = "#d981de";
              font_style = null;
              font_weight = null;
            };
            comment = {
              color = "#6f737a";
              font_style = "italic";
              font_weight = null;
            };
            "comment.doc" = {
              color = "#6f737a";
              font_style = "italic";
              font_weight = null;
            };
            constant = {
              color = "#72cfd6";
              font_style = null;
              font_weight = 700;
            };
            constructor = {
              color = "#debc7e";
              font_style = null;
              font_weight = null;
            };
            embedded = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
            emphasis = {
              color = "#ced0d6";
              font_style = "italic";
              font_weight = null;
            };
            "emphasis.strong" = {
              color = "#ced0d6";
              font_style = null;
              font_weight = 700;
            };
            enum = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
            function = {
              color = "#debc7e";
              font_style = null;
              font_weight = null;
            };
            "function.method" = {
              color = "#debc7e";
              font_style = null;
              font_weight = null;
            };
            "function.special.definition" = {
              color = "#debc7e";
              font_style = null;
              font_weight = null;
            };
            hint = {
              color = "#6f737a";
              font_style = null;
              font_weight = 700;
            };
            keyword = {
              color = "#749ded";
              font_style = null;
              font_weight = null;
            };
            label = {
              color = "#548af7";
              font_style = null;
              font_weight = null;
            };
            link_text = {
              color = "#548af7";
              font_style = null;
              font_weight = null;
            };
            link_uri = {
              color = "#548af7";
              font_style = null;
              font_weight = null;
            };
            number = {
              color = "#d981de";
              font_style = null;
              font_weight = null;
            };
            operator = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
            predictive = {
              color = "#6f737a";
              font_style = "italic";
              font_weight = null;
            };
            preproc = {
              color = "#debc7e";
              font_style = null;
              font_weight = null;
            };
            primary = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
            property = {
              color = "#72cfd6";
              font_style = null;
              font_weight = null;
            };
            punctuation = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
            "punctuation.bracket" = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
            "punctuation.delimiter" = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
            "punctuation.list_marker" = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
            "punctuation.special" = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
            string = {
              color = "#7ec482";
              font_style = null;
              font_weight = null;
            };
            "string.escape" = {
              color = "#d981de";
              font_style = null;
              font_weight = null;
            };
            "string.regex" = {
              color = "#7ec482";
              font_style = null;
              font_weight = null;
            };
            "string.special" = {
              color = "#7ec482";
              font_style = null;
              font_weight = null;
            };
            "string.special.symbol" = {
              color = "#7ec482";
              font_style = null;
              font_weight = null;
            };
            tag = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
            "text.literal" = {
              color = "#7ec482";
              font_style = null;
              font_weight = null;
            };
            title = {
              color = "#debc7e";
              font_style = null;
              font_weight = 700;
            };
            type = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
            "type.builtin" = {
              color = "#749ded";
              font_style = null;
              font_weight = null;
            };
            "type.interface" = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
            variable = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
            "variable.member" = {
              color = "#72cfd6";
              font_style = null;
              font_weight = null;
            };
            "variable.parameter" = {
              color = "#b189f5";
              font_style = null;
              font_weight = null;
            };
            "variable.special" = {
              color = "#b189f5";
              font_style = null;
              font_weight = null;
            };
            variant = {
              color = "#ced0d6";
              font_style = null;
              font_weight = null;
            };
          };
        };
      }
    ];
  };
in
{

  options.myOS.programs.zed = with lib; {

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
          dark = "Islands Dark";
        };

        ui_font_family = "Inter";
        ui_font_size = 20;

      };

      # Add the Islands Dark theme file
      ".config/zed/themes/islands-dark.json".text = builtins.toJSON islandsDarkTheme;
    };
  };
}
