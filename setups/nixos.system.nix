{
  config,
  pkgs,
  lib,
  configVars,
  pkgsStable,
  ...
}:

{

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = [ configVars.username ];
    };

    firefox.enable = true;
    hyprland.enable = false;

    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
    # mtr.enable = true; # Some programs need SUID wrappers, can be configured further or are started in user sessions
  };

  services = {
    flatpak.enable = true;

    # services.openssh.enable = true;

    # CUPS
    printing.enable = true;

    # Audio & Video
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Wayland
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb.layout = configVars.keyboardLayout;

      # libinput.enable = true; # Enable touchpad support (enabled default in most desktopManager).
    };
  };

  virtualisation.docker = {
    enable = true;

    rootless = {
      enable = true;
      setSocketVariable = true;
    };

    daemon.settings = {
      userland-proxy = false;
    };
  };

  environment = {

    sessionVariables = {
      NIXOS_OZONE_WL = "1";

      GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (
        with pkgs.gst_all_1;
        [
          gstreamer
          gst-plugins-base
          gst-plugins-good
          gst-plugins-bad
          gst-plugins-ugly
          gst-libav
          gst-vaapi
        ]
      );
    };

    systemPackages = with pkgs; [ ];

    gnome.excludePackages = with pkgs; [
      epiphany # web browser
      file-roller # archive manager
      geary # email client
      seahorse # password manager
      simple-scan # document scanner
      totem # video player
      yelp # help viewer

      gnome-calendar
      gnome-connections
      gnome-contacts
      gnome-logs
      gnome-maps
      gnome-maps
      gnome-music
      gnome-screenshot
      gnome-shell-extensions
      gnome-software
      gnome-tour
    ];

  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  imports = [
    # Include the results of the hardware scan.
    ./nixos.hardware.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true; # Enable networking

    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # proxy = {
    #   default = "http://user:password@proxy:port/";
    #   noProxy = "127.0.0.1,localhost,internal.domain";
    # };

    # firewall = {
    #   enable = false;
    #   allowedTCPPorts = [ ... ];
    #   allowedUDPPorts = [ ... ];
    # };
  };

  i18n = {
    defaultLocale = configVars.defaultLocale;

    extraLocaleSettings = {
      LC_ADDRESS = configVars.extraLocale;
      LC_IDENTIFICATION = configVars.extraLocale;
      LC_MEASUREMENT = configVars.extraLocale;
      LC_MONETARY = configVars.extraLocale;
      LC_NAME = configVars.extraLocale;
      LC_NUMERIC = configVars.extraLocale;
      LC_PAPER = configVars.extraLocale;
      LC_TELEPHONE = configVars.extraLocale;
      LC_TIME = configVars.extraLocale;
    };
  };

  time.timeZone = configVars.timezone; # Set your time zone.
  hardware.pulseaudio.enable = false; # Enable sound with pipewire.
  security.rtkit.enable = true; # hands out realtime scheduling priority to user processes on demand
  xdg.portal.config.common.default = "gtk"; # XDG backend for flatpak

  users.users.elias = {
    isNormalUser = true;
    description = configVars.username;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

}
