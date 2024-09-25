{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    procs # A modern replacement for ps written in Rust

  ];

}
