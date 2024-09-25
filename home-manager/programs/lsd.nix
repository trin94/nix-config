{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    lsd # The next gen ls command
  ];

  programs.lsd = {
    enable = true;

    settings = {
      blocks = [
        "permission"
        "user"
        "date"
        "name"
      ];

      date = "+%d %b %H:%M";

      icons = {
        "when" = "never";
      };

      sorting = {
        "dir-grouping" = "first";
      };

    };
  };

}
