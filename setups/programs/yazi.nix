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

    programs.yazi = {
      enable = true;

      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.yazi.enable

      enableFishIntegration = true;
      enableNushellIntegration = true;
      shellWrapperName = "y";

      initLua = ''
        require("git"):setup()
      '';

      settings = {
        mgr = {
          ratio = [
            0
            4
            3
          ];

          show_hidden = true;
          linemode = "size";

          sort_by = "natural";
          sort_sensitive = false;
          sort_dir_first = true;
          sort_translit = true;
        };

        plugin.prepend_fetchers = [
          {
            url = "*";
            run = "git";
            group = "git";
          }
          {
            url = "*/";
            run = "git";
            group = "git";
          }
        ];

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
            run = "shell fish --block";
            desc = "Open fish here";
          }
          {
            on = "<C-h>";
            run = "hidden toggle";
            desc = "Toggle hidden files";
          }
        ];
      };

      plugins = {
        smart-enter = "${pkgs.yaziPlugins.smart-enter}";
        git = "${pkgs.yaziPlugins.git}";
      };

    };

  };

}
