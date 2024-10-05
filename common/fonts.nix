{
  config,
  pkgs,
  lib,
  ...
}:

{

  home.packages = with pkgs; [

    # Normal fonts
    google-fonts
    inter
    ubuntu_font_family

    # Nerd fonts
    (nerdfonts.override {
      fonts = [
        "CascadiaCode"
        "JetBrainsMono"
        "UbuntuMono"
      ];
    })

  ];
}
