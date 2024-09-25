{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    hugo # A fast and modern static website engine
  ];

}
