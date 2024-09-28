{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}:

let
  disabled = [ "" ];
in
{
  # https://github.com/NixOS/nixpkgs/blob/master/lib/gvariant.nix
  # https://github.com/wimpysworld/nix-config/blob/main/nixos/_mixins/desktop/gnome/default.nix

  dconf.settings = with lib.gvariant; {

    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };

    "org/gnome/desktop/background" = {
      "picture-uri" = lib.mkIf (builtins.hasAttr "wallpaperPathLight" userConfig) "file://${userConfig.wallpaperPathLight}";
      "picture-uri-dark" = lib.mkIf (builtins.hasAttr "wallpaperPathDark" userConfig) "file://${userConfig.wallpaperPathDark}";
    };

    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      clock-show-weekday = true;

      enable-hot-corners = false;
      enable-animations = false;

      font-name = "Inter 11";
      document-font-name = "Inter 11";
      monospace-font-name = "CaskaydiaCove NF Bold 16";
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = mkDouble 0.6;
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

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "org.gnome.TextEditor.desktop"
        "firefox.desktop"
        "jetbrains-toolbox.desktop"
        "io.bassi.Amberol.desktop"
        "steam.desktop"
        "com.discordapp.Discord.desktop"
        "org.telegram.desktop.desktop"
        "com.microsoft.Teams.desktop"
        "com.teamspeak.TeamSpeak.desktop"
      ];
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

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-timeout = mkUint32 0;
      sleep-inactive-ac-type = "nothing";
    };

    "org/gtk/Settings/FileChooser".clock-format = "12h";
    "org/gtk/gtk4/Settings/FileChooser".clock-format = "12h";

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
      command = "alacritty";
    };

  };
}
