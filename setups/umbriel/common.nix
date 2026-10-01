{
  general = {
    show_cheatsheet = false;

    autostart = [ "noctalia -d" ];
  };

  input = {
    keyboard = {
      layout = "de";
      variant = "us";
      options = "lv3:rwin_switch";
    };
    mouse = {
      sensitivity = 1.0;
      accel_profile = "flat";
    };
    cursor = {
      theme = "breeze_cursors";
      size = 22;
      follows_focus = false;
    };
    focus.follows_mouse = false;
  };

  layout = {
    mode = "scrolling";
    gap = 24;
    extent_presets = [
      0.3334
      0.5
      0.6667
      1.0
    ];
    scrolling = {
      center_focused = "never";
      center_underfull_strip = false;
    };
  };

  workspaces.empty_above = true;

  appearance = {
    prefer_no_csd = true;
    border_width = 5;
    outer_border_width = 0;
    corner_radius = 0;
    blur.enabled = true;
    shadow = {
      enabled = true;
      softness = 30;
      offset_x = 0;
      offset_y = 5;
    };
  };

  colors = {
    border = {
      focused = "#7fc8ff";
      unfocused = "#505050";
    };
    shadow = "#00000077";
    overview.background_tint = "#262626ff";
  };

  animation = {
    enabled = true;
    duration_ms = 225;
    curve = "easeout";

    windows_in = {
      enabled = true;
      duration_ms = 150;
      curve = "easeoutexpo";
      effect = "window-scale-fade";
    };
    windows_out = {
      enabled = true;
      duration_ms = 150;
      curve = "easeoutquad";
      effect = "window-scale-fade";
    };

    # Springs ignore duration_ms; speed is controlled by stiffness.
    windows_move.curve = "spring:1,1100";
    workspaces.curve = "spring:1,1000";
    overview = {
      enabled = true;
      curve = "spring:1,1000";
      workspace_curve = "spring:1,1200";
    };
    scratchpad = {
      enabled = true;
      curve = "spring:1,1000";
    };
    border.curve = "spring:1,1100";
  };

  effects.preset.window-scale-fade = {
    kind = "animation";
    shader = "${./window-scale-fade.glsl}";
  };

  overview = {
    zoom = 0.33;
    background_blur = false;
    shortcuts = false;
  };

  hot_corners = {
    top_left.enabled = false;
    top_right.enabled = false;
    bottom_left.enabled = false;
    bottom_right.enabled = false;
  };

  window_rule = [
    {
      # Keep the global extent unset: WezTerm cannot clear an inherited default.
      match.app_id = "^(?!org[.]wezfurlong[.]wezterm$).*";
      default_scrolling_extent = 0.5;
    }
    {
      match = {
        app_id = "firefox$";
        title = "^Picture-in-Picture$";
      };
      default_floating = true;
    }
    {
      match.app_id = "io.github.mpvqc.python3";
      default_floating = true;
    }
    {
      match.app_id = "org.telegram.desktop|TeamSpeak 3";
      default_scrolling_extent = 0.25;
    }
    {
      match.app_id = "org.chromium.Chromium|org.mozilla.firefox|^jetbrains-|^spotify";
      default_scrolling_extent = 1.0;
    }
    {
      match.app_id = "^[Ss]team$";
      default_focused = false;
    }
    {
      match.app_id = "^kitty$";
      default_scrolling_extent = 0.6667;
    }
    {
      match = {
        app_id = "dev.zed.Zed";
        title = "^Zed — Settings$";
      };
      default_floating = true;
    }
    # Proton Pass is not excluded from screenshots or screencasts.
  ];

  # These bindings supplement built-ins; omitted shortcuts remain active.
  keybinds = {
    "Mod+Shift+Slash" = "cheatsheet-toggle";
    "Mod+Return" = "spawn:kitty";
    "Mod+Space" = "spawn:noctalia msg panel-toggle launcher";

    "Mod+Tab" = {
      action = "overview-toggle";
      repeat = false;
    };
    "Alt+Tab" = {
      action = "overview-toggle";
      repeat = false;
    };
    "Mod+Shift+Q" = {
      action = "window-close";
      repeat = false;
    };

    "Mod+H" = "window-focus-left";
    "Mod+L" = "window-focus-right";
    "Mod+K" = "workspace-previous";
    "Mod+J" = "workspace-next";

    "Mod+Shift+H" = "column-move-left";
    "Mod+Shift+L" = "column-move-right";
    "Mod+Shift+K" = "column-move-to-workspace-previous";
    "Mod+Shift+J" = "column-move-to-workspace-next";

    "Alt+Up" = "window-move-up";
    "Alt+Down" = "window-move-down";

    "Mod+WheelDown" = {
      action = "window-focus-right";
      cooldown_ms = 150;
    };
    "Mod+WheelUp" = {
      action = "window-focus-left";
      cooldown_ms = 150;
    };
    "Ctrl+Mod+WheelDown" = {
      action = "workspace-next";
      cooldown_ms = 150;
    };
    "Ctrl+Mod+WheelUp" = {
      action = "workspace-previous";
      cooldown_ms = 150;
    };

    "Mod+BracketLeft" = "window-consume-or-expel-left";
    "Mod+BracketRight" = "window-consume-or-expel-right";
    "Mod+Comma" = "window-consume-or-expel-left";
    "Mod+Period" = "window-consume-or-expel-right";

    "Mod+R" = "window-cycle-primary-extent";
    # Width and height share extent_presets.
    "Mod+Shift+R" = "window-cycle-secondary-extent";
    "Mod+F" = "window-toggle-maximize";
    "Mod+Shift+F" = "window-toggle-fullscreen";
    # Suppress the built-in maximize shortcut without changing the layout.
    "Mod+Ctrl+F" = {
      action = "spawn:true";
      repeat = false;
    };

    "Mod+Minus" = "window-modify-primary-extent:-0.1";
    "Mod+Equal" = "window-modify-primary-extent:+0.1";
    "Mod+Shift+Minus" = "window-modify-secondary-extent:-0.1";
    "Mod+Shift+Equal" = "window-modify-secondary-extent:+0.1";

    "Mod+V" = "window-toggle-floating";
    "Mod+Shift+V" = "window-focus-switch-floating";

    "Print" = "spawn:noctalia msg screenshot-region";
    "Ctrl+Print" = "spawn:noctalia msg screenshot-fullscreen";
    # Leave Alt+Print unbound: whole-screen capture is not a safe window-only fallback.

    "Mod+Escape" = {
      action = "shortcuts-inhibit-toggle";
      allow_when_inhibited = true;
    };

    # Require confirmation before logout.
    "Mod+Shift+E" = {
      action = "session-quit";
      repeat = false;
    };
    "Ctrl+Alt+Delete" = {
      action = "session-quit";
      repeat = false;
    };
    "Mod+Shift+P" = "dpms-off";
  };
}
