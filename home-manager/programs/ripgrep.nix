{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    ripgrep # A utility that combines the usability of The Silver Searcher with the raw speed of grep

  ];

}
