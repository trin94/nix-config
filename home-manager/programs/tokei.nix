{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    tokei # A program that allows you to count your code, quickly

  ];

}
