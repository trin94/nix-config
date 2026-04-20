{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.myOS.programs.vim;
in
{

  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  options.myOS.programs.vim = with lib; {

    enable = mkEnableOption "vim";

  };

  config = lib.mkIf cfg.enable {

    programs.nixvim = {
      enable = true;

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      extraPlugins = with pkgs.vimPlugins; [
        vim-just
        dracula-vim # Dracula theme plugin
      ];

      plugins = {
        gitsigns.enable = true;
        lualine.enable = true;
        rainbow-delimiters.enable = true;
        startify.enable = true;
        treesitter.enable = true;
        vim-css-color.enable = true;
      };

      opts = {
        langmenu = "en_US";

        # Search
        showmatch = true; # show matching
        ignorecase = true; # case insensitive
        incsearch = true; # incremental search

        # Indentation
        tabstop = 4; # 4 spaces -> 1 tab
        softtabstop = 4; # see multiple spaces as tabstops so <BS> does the right thing
        shiftwidth = 4; # width for auto indents
        expandtab = true; # converts tabs to white space
        smarttab = true;
        autoindent = true;

        number = true; # -- add line numbers
        wildmode = "longest,list"; # -- get bash-like tab completions
        showmode = false;

        clipboard = "unnamedplus";
        cursorline = true;

        mouse = "nicr";
        backup = false;
        swapfile = false;
        fileformat = "unix";
        encoding = "utf-8";
      };

      keymaps = [
        {
          mode = [
            "n"
            "i"
          ];
          key = "<Up>";
          action = "<Nop>";
        }
        {
          mode = [
            "n"
            "i"
          ];
          key = "<Down>";
          action = "<Nop>";
        }
        {
          mode = [
            "n"
            "i"
          ];
          key = "<Left>";
          action = "<Nop>";
        }
        {
          mode = [
            "n"
            "i"
          ];
          key = "<Right>";
          action = "<Nop>";
        }
      ];

      extraConfigLua = '''';

    };
  };

}
