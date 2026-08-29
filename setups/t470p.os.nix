{
  pkgs,
  ...
}:
let
  username = "elias";
in
{

  imports = [
    ./t470p.hardware.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "t470p";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "de";

  users.users.${username} = {
    isNormalUser = true;
    description = "Elias Mueller";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
  };

  # Session. niri ships the wayland-session entry the greeter lists, the
  # systemd user service, and a fully configured xdg-desktop-portal, so the
  # home-manager niri module stays disabled on this host.
  programs.niri = {
    enable = true;
    useNautilus = true;
  };

  # niri hardcodes enableXWayland = false; X11 clients reach it through
  # xwayland-satellite, spawned from t470p.niri.kdl.
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    nautilus
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    # NetworkManager, bluetooth, UPower, power-profiles-daemon. The shell's
    # widgets are dead without them.
    recommendedServices.enable = true;
  };

  services.displayManager.noctalia-greeter = {
    enable = true;

    settings.keyboard.layout = "de";

    cursorTheme = {
      package = pkgs.kdePackages.breeze;
      name = "breeze_cursors";
    };
  };

  hardware.graphics.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Graphical programs. Flathub is not declarative, add it once per machine
  services.flatpak.enable = true;

  # The greeter renders before any user session exists, so it cannot see
  # home-manager's fontconfig. MonoLisa stays in home-manager.
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # Lets unpatched binaries find a dynamic linker: uv-managed CPython and PyPI
  # wheels with native code (PySide6, ruff, prek), and the JetBrains IDEs that
  # Toolbox downloads into $HOME.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      alsa-lib
      brotli
      dbus
      expat
      fontconfig
      freetype
      glib
      icu
      keyutils.lib
      libdrm
      libffi
      libglvnd
      libkrb5
      libpng
      libselinux
      libxkbcommon
      libxml2
      openssl
      pcre2
      stdenv.cc.cc.lib
      systemdLibs
      wayland
      zlib
      zstd
      libice
      libsm
      libx11
      libxcb
      libxcb-cursor
      libxcb-image
      libxcb-keysyms
      libxcb-render-util
      libxcb-wm
      libxcursor
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxtst

      # JetBrains IDEs, on top of everything above. Taken from what nixpkgs
      # links its own jetbrains.* packages against. This block is the bundled
      # JCEF, the chromium the IDEs embed for the login window and the docs
      # preview.
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      libgbm
      libxcomposite
      libxdamage
      nspr
      nss
      pango

      # Reached through JNA: keychain, notifications, Help > Collect Logs.
      e2fsprogs
      libnotify
      libsecret
    ];
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      username
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # Matches the release this machine was installed from. Do not bump.
  system.stateVersion = "26.05";

}
