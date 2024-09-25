{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    bat # A cat(1) clone with syntax highlighting and Git integration
  ];

}
