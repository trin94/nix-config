{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.yazi;
in
{

  options.myOS.programs.yazi = with lib; {
    enable = mkEnableOption "yazi";
  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      yazi
    ];

    programs.yazi = {
      enable = true;

      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.yazi.enable

      enableFishIntegration = true;
      enableNushellIntegration = true;

      settings = {
        mgr = {
          sort_by = "natural";
          sort_sensitive = false;
          sort_dir_first = true;
          sort_translit = true;
        };

        opener = {
          play = [
            {
              run = ''flatpak run io.mpv.Mpv "$@" '';
              orphan = true;
              for = "unix";
            }
          ];
        };
      };

      keymap = {
        mgr.prepend_keymap = [
          {
            on = "l";
            run = "plugin smart-enter";
            desc = "Enter directory or open file";
          }
          {
            on = "!";
            for = "unix";
            run = ''shell fish --block'';
            desc = "Open fish here";
          }
        ];
      };

      plugins = {
        smart-enter = "${pkgs.yaziPlugins.smart-enter}";
      };

    };

  };

}
