{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    dtrx # Do The Right Extraction: A tool for taking the hassle out of extracting archives
  ];

}
