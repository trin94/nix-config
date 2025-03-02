{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.myOS.desktop.gnome;
  disabled = [ "" ];
  ptyxisProfileUUID = "a6d8c5d2-7fdf-434d-b2c1-5a6e0df9696a";
in
{

  options.myOS.desktop.gnome = with lib; {

    configure = mkEnableOption "gnome";

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

    dockApps = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

  };

  config = lib.mkIf cfg.configure {

    # https://github.com/NixOS/nixpkgs/blob/master/lib/gvariant.nix
    # https://github.com/wimpysworld/nix-config/blob/main/nixos/_mixins/desktop/gnome/default.nix

    dconf.settings = with lib.gvariant; {

      "org/gnome/desktop/datetime" = {
        automatic-timezone = true;
      };

      "org/gnome/desktop/background" = {
        "picture-uri" = lib.mkIf (cfg.wallpaper != null) cfg.wallpaper;
        "picture-uri-dark" = lib.mkIf (cfg.wallpaperDark != null) cfg.wallpaperDark;
      };

      "org/gnome/desktop/interface" = {
        clock-format = "12h";
        clock-show-weekday = true;

        enable-hot-corners = false;
        # enable-animations = false;

        font-name = "Adwaita Sans 11";
        document-font-name = "Adwaita Sans 11";
        monospace-font-name = "CaskaydiaCove NF Bold 14";
      };

      "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "flat";
        speed = mkDouble 0.6;
      };

      "org/gnome/desktop/privacy" = {
        remember-recent-files = false;
      };

      "org/gnome/desktop/session" = {
        idle-delay = mkUint32 900;
      };

      "org/gnome/desktop/wm/keybindings" = {
        close = [ "<Shift><Super>q" ];
        activate-window-menu = disabled;
        always-on-top = disabled;
        begin-move = disabled;
        begin-resize = disabled;
        cycle-group = disabled;
        cycle-group-backward = disabled;
        cycle-panels = disabled;
        cycle-panels-backward = disabled;
        cycle-windows = disabled;
        cycle-windows-backward = disabled;
        lower = disabled;
        maximize = [ "<Super>Up" ];
        maximize-horizontally = disabled;
        maximize-vertically = disabled;
        minimize = disabled;
        move-to-center = disabled;
        move-to-corner-ne = disabled;
        move-to-corner-nw = disabled;
        move-to-corner-se = disabled;
        move-to-corner-sw = disabled;
        move-to-monitor-down = disabled;
        move-to-monitor-left = disabled;
        move-to-monitor-right = disabled;
        move-to-monitor-up = disabled;
        move-to-side-e = disabled;
        move-to-side-n = disabled;
        move-to-side-s = disabled;
        move-to-side-w = disabled;
        move-to-workspace-1 = disabled;
        move-to-workspace-10 = disabled;
        move-to-workspace-11 = disabled;
        move-to-workspace-12 = disabled;
        move-to-workspace-2 = disabled;
        move-to-workspace-3 = disabled;
        move-to-workspace-4 = disabled;
        move-to-workspace-5 = disabled;
        move-to-workspace-6 = disabled;
        move-to-workspace-7 = disabled;
        move-to-workspace-8 = disabled;
        move-to-workspace-9 = disabled;
        move-to-workspace-down = disabled;
        move-to-workspace-last = disabled;
        move-to-workspace-left = [ "<Control><Shift><Alt>Left" ];
        move-to-workspace-right = [ "<Control><Shift><Alt>Right" ];
        move-to-workspace-up = disabled;
        panel-main-menu = disabled;
        panel-run-dialog = [ "<Alt>F2" ];
        raise = disabled;
        raise-or-lower = disabled;
        set-spew-mark = disabled;
        show-desktop = disabled;
        switch-applications = [ "<Alt>Tab" ];
        switch-applications-backward = [ "<Shift><Alt>Tab" ];
        switch-group = disabled;
        switch-group-backward = disabled;
        switch-input-source = disabled;
        switch-input-source-backward = disabled;
        switch-panels = disabled;
        switch-panels-backward = disabled;
        switch-to-workspace-1 = disabled;
        switch-to-workspace-10 = disabled;
        switch-to-workspace-11 = disabled;
        switch-to-workspace-12 = disabled;
        switch-to-workspace-2 = disabled;
        switch-to-workspace-3 = disabled;
        switch-to-workspace-4 = disabled;
        switch-to-workspace-5 = disabled;
        switch-to-workspace-6 = disabled;
        switch-to-workspace-7 = disabled;
        switch-to-workspace-8 = disabled;
        switch-to-workspace-9 = disabled;
        switch-to-workspace-down = disabled;
        switch-to-workspace-last = disabled;
        switch-to-workspace-left = [ "<Control><Alt>Left" ];
        switch-to-workspace-right = [ "<Control><Alt>Right" ];
        switch-to-workspace-up = disabled;
        switch-windows = disabled;
        switch-windows-backward = disabled;
        toggle-above = disabled;
        toggle-fullscreen = disabled;
        toggle-maximized = disabled;
        toggle-on-all-workspaces = disabled;
        unmaximize = [ "<Super>Down" ];
      };

      "org/gnome/mutter" = {
        dynamic-workspaces = true;
        workspaces-only-on-primary = true;
      };

      "org/gnome/nautilus/list-view" = {
        default-zoom-level = "small";
      };

      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
      };

      "org/gnome/shell" = {
        favorite-apps = cfg.dockApps;
      };

      "org/gnome/TextEditor" = {
        highlight-current-line = true;
        indent-style = "space";
        show-grid = false;
        show-line-numbers = true;
        show-map = true;
        show-right-margin = true;
        style-scheme = "builder-dark";
        tab-width = mkUint32 4;
        use-system-font = true;
      };

      "org/gnome/Ptyxis" = {
        audible-bell = false;
        cursor-blink-mode = "system";
        default-columns = mkUint32 120;
        default-rows = mkUint32 30;
        enable-a11y = false;
        restore-window-size = false;
        visual-bell = false;
        default-profile-uuid = ptyxisProfileUUID;
        profile-uuids = [ ptyxisProfileUUID ];
      };

      "org/gnome/Ptyxis/Profiles/${ptyxisProfileUUID}" = {
        palette = "nord";
        preseve-directory = "never";
        scroll-on-output = true;
      };

      "org/gnome/settings-daemon/plugins/power" = {
        power-button-action = "interactive";
        sleep-inactive-ac-timeout = mkUint32 0;
        sleep-inactive-ac-type = "nothing";
      };

      "org/gtk/Settings/FileChooser".clock-format = "12h";
      "org/gtk/gtk4/Settings/FileChooser".clock-format = "12h";

      "org/gnome/desktop/input-sources" = {
        xkb-options = [ "lv3:rwin_switch" ]; # altGr on my keyboards :|
      };

      #
      # Set custom keybindings

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "Terminal";
        binding = "<Super>Return";
        command = cfg.terminalApp;
      };

    };

  };

}
