{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myOS.programs.kitty;
  fontConfig =
    if cfg.useMonoLisaFont then
      ''
        font_family      MonoLisaCode Variable
        bold_font        auto
        italic_font      auto
        bold_italic_font auto
        font_size 14
      ''
    else
      ''
        font_family CaskaydiaCove NF
        bold_font CaskaydiaCove NF Bold
        italic_font CaskaydiaCove NF Italic
        bold_italic_font CaskaydiaCove NF Bold Italic
        font_size 14
      '';

  themesDir = "${pkgs.kitty-themes}/share/kitty-themes/themes";

  kittyConfPath = "${config.home.homeDirectory}/.config/kitty/kitty.conf";

  kittyConfText = ''
    auto_reload_config ${if cfg.followNoctaliaTheme then "0.1" else "-1"}
    cursor_blink_interval 0.5
    cursor_shape beam
    copy_on_select clipboard
    shell ${config.home.profileDirectory}/bin/fish
    window_padding_width 5
    initial_window_width 120c
    initial_window_height 30c
    background_opacity ${toString cfg.backgroundOpacity}
    ${fontConfig}
    sync_to_monitor yes
    linux_display_server wayland
    ${if cfg.enableCsd then "wayland_titlebar_color system" else "hide_window_decorations yes"}
    map ctrl+f no_op
    map ctrl+r no_op
    map ctrl+shift+f no_op
    map ctrl+shift+r no_op
    map ctrl+shift+n no_op
    ${lib.optionalString cfg.followNoctaliaTheme "include themes/noctalia.conf"}
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
      description = "Use MonoLisaCode Variable font";
    };

    followSystemTheme = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Let kitty manage its own colors and switch between a dark and light
        theme based on the system color scheme. Disable when another tool
        (e.g. stylix) is theming kitty.
      '';
    };

    followNoctaliaTheme = mkOption {
      type = types.bool;
      default = false;
    };

    backgroundOpacity = mkOption {
      type = types.float;
      default = 1.0;
      description = ''
        Kitty window background opacity. Values below 1.0 make the window
        semi-transparent, which is what lets compositor blur show through.
      '';
    };

  };

  config = lib.mkIf cfg.configure {

    assertions = [
      {
        assertion = !(cfg.followSystemTheme && cfg.followNoctaliaTheme);
        message = ''
          myOS.programs.kitty: followSystemTheme and followNoctaliaTheme are
          both set. Kitty applies the *.auto.conf themes on top of the include,
          so the noctalia colors would never show.
        '';
      }
    ];

    # noctalia's apply.sh starts with `touch kitty.conf` and dies on a store
    # symlink, so it never reaches the SIGUSR1 that reloads the colors. Give it
    # a real writable file to touch.
    home.activation = lib.optionalAttrs cfg.followNoctaliaTheme {
      copyKittyConf = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        mkdir -p $(dirname "${kittyConfPath}")
        rm -f "${kittyConfPath}"
        cp -f ${pkgs.writeText "kitty.conf" kittyConfText} "${kittyConfPath}"
        chmod 644 "${kittyConfPath}"
      '';
    };

    xdg.configFile =
      lib.optionalAttrs (!cfg.followNoctaliaTheme) {
        "kitty/kitty.conf".text = kittyConfText;
      }
      // lib.optionalAttrs cfg.followSystemTheme {
        "kitty/dark-theme.auto.conf".source = "${themesDir}/Catppuccin-Mocha.conf";
        "kitty/light-theme.auto.conf".source = "${themesDir}/adwaita_light.conf";
        "kitty/no-preference-theme.auto.conf".source = "${themesDir}/adwaita_light.conf";
      };
  };

}
