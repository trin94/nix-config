{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    yq-go # Portable command-line YAML processor
  ];

}
