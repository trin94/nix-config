{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    fastfetch # Like neofetch, but much faster because written in C
  ];

}
