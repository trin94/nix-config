{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    just # A handy way to save and run project-specific commands
  ];

}
