{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    fd # A simple, fast and user-friendly alternative to find
  ];

}
