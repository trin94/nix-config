{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    _1password # Multi-platform password manager CLI
    _1password-gui # Multi-platform password manager
  ];

  #  programs._1password.enable = true;
  #  programs._1password-gui = {
  #    enable = true;
  #    # Certain features, including CLI integration and system authentication support,
  #    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
  #    polkitPolicyOwners = [ "elias" ];
  #  };

}
