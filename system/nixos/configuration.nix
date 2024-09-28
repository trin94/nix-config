{
  config,
  pkgs,
  userConfig,
  pkgs-stable,
  ...
}:

{

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = [ userConfig.username ];
    };

    firefox.enable = true;

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
      xkb.layout = userConfig.keyboardLayout;

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
    ./hardware-configuration.nix
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
    hostName = userConfig.hostname;
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
    defaultLocale = userConfig.defaultLocale;

    extraLocaleSettings = {
      LC_ADDRESS = userConfig.extraLocale;
      LC_IDENTIFICATION = userConfig.extraLocale;
      LC_MEASUREMENT = userConfig.extraLocale;
      LC_MONETARY = userConfig.extraLocale;
      LC_NAME = userConfig.extraLocale;
      LC_NUMERIC = userConfig.extraLocale;
      LC_PAPER = userConfig.extraLocale;
      LC_TELEPHONE = userConfig.extraLocale;
      LC_TIME = userConfig.extraLocale;
    };
  };

  time.timeZone = userConfig.timezone; # Set your time zone.
  hardware.pulseaudio.enable = false; # Enable sound with pipewire.
  security.rtkit.enable = true; # hands out realtime scheduling priority to user processes on demand
  xdg.portal.config.common.default = "gtk"; # XDG backend for flatpak

  users.users.elias = {
    isNormalUser = true;
    description = userConfig.username;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

}
