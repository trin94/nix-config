{
  config,
  pkgs,
  lib,
  ...
}:

{

  home.packages = with pkgs; [

    google-fonts
    inter
    ubuntu_font_family

    nerd-fonts.ubuntu-sans
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove

  ];
}
