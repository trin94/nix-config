{
  config,
  pkgs,
  libs,
  inputs,
  ...
}:

{

  imports = [ inputs.nixvim.nixosModules.nixvim ];

  programs.nixvim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.one.enable = true;

    extraPlugins = with pkgs.vimPlugins; [ vim-just ];

    plugins = {
      startify.enable = true;
      lightline.enable = true;
      treesitter.enable = true;
      rainbow-delimiters.enable = true;
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

    extraConfigLua = ''
      vim.g.lightline = {
        colorscheme = "one"
      }

      -- Add new line to the end of files
      vim.api.nvim_create_autocmd({"BufWritePre"}, {
        group = vim.api.nvim_create_augroup('UserOnSave', {}),
        pattern = '*',
        callback = function()
          local n_lines = vim.api.nvim_buf_line_count(0)
          local last_nonblank = vim.fn.prevnonblank(n_lines)
          if last_nonblank <= n_lines then vim.api.nvim_buf_set_lines(0,
            last_nonblank, n_lines, true, { "" })
          end
        end,
      })

      -- Remove trailing white spaces
      vim.api.nvim_create_autocmd({ "BufWritePre" }, {
          pattern = {"*"},
          callback = function(ev)
              save_cursor = vim.fn.getpos(".")
              pcall(function() vim.cmd [[%s/\s\+$//e]] end)
              vim.fn.setpos(".", save_cursor)
          end,
      })
    '';

    /*
      https://nix-community.github.io/nixvim/NeovimOptions/highlight/index.html
      highlight LineNr           ctermfg=8    ctermbg=none    cterm=none
      highlight CursorLineNr     ctermfg=7    ctermbg=8       cterm=none
      highlight VertSplit        ctermfg=0    ctermbg=8       cterm=none
      highlight Statement        ctermfg=2    ctermbg=none    cterm=none
      highlight Directory        ctermfg=4    ctermbg=none    cterm=none
      highlight StatusLine       ctermfg=7    ctermbg=8       cterm=none
      highlight StatusLineNC     ctermfg=7    ctermbg=8       cterm=none
      highlight Comment          ctermfg=4    ctermbg=none    cterm=none
      highlight Constant         ctermfg=12   ctermbg=none    cterm=none
      highlight Special          ctermfg=4    ctermbg=none    cterm=none
      highlight Identifier       ctermfg=6    ctermbg=none    cterm=none
      highlight PreProc          ctermfg=5    ctermbg=none    cterm=none
      highlight String           ctermfg=12   ctermbg=none    cterm=none
      highlight Number           ctermfg=1    ctermbg=none    cterm=none
      highlight Function         ctermfg=1    ctermbg=none    cterm=none

      " highlight WildMenu         ctermfg=0       ctermbg=80      cterm=none
      " highlight Folded           ctermfg=103     ctermbg=234     cterm=none
      " highlight FoldColumn       ctermfg=103     ctermbg=234     cterm=none
      " highlight DiffAdd          ctermfg=none    ctermbg=23      cterm=none
      " highlight DiffChange       ctermfg=none    ctermbg=56      cterm=none
      " highlight DiffDelete       ctermfg=168     ctermbg=96      cterm=none
      " highlight DiffText         ctermfg=0       ctermbg=80      cterm=none
      " highlight SignColumn       ctermfg=244     ctermbg=235     cterm=none
      " highlight Conceal          ctermfg=251     ctermbg=none    cterm=none
      " highlight SpellBad         ctermfg=168     ctermbg=none    cterm=underline
      " highlight SpellCap         ctermfg=80      ctermbg=none    cterm=underline
      " highlight SpellRare        ctermfg=121     ctermbg=none    cterm=underline
      " highlight SpellLocal       ctermfg=186     ctermbg=none    cterm=underline
      " highlight Pmenu            ctermfg=251     ctermbg=234     cterm=none
      " highlight PmenuSel         ctermfg=0       ctermbg=111     cterm=none
      " highlight PmenuSbar        ctermfg=206     ctermbg=235     cterm=none
      " highlight PmenuThumb       ctermfg=235     ctermbg=206     cterm=none
      " highlight TabLine          ctermfg=244     ctermbg=234     cterm=none
      " highlight TablineSel       ctermfg=0       ctermbg=247     cterm=none
      " highlight TablineFill      ctermfg=244     ctermbg=234     cterm=none
      " highlight CursorColumn     ctermfg=none    ctermbg=236     cterm=none
      " highlight CursorLine       ctermfg=none    ctermbg=236     cterm=none
      " highlight ColorColumn      ctermfg=none    ctermbg=236     cterm=none
      " highlight Cursor           ctermfg=0       ctermbg=5       cterm=none
      " highlight htmlEndTag       ctermfg=114     ctermbg=none    cterm=none
      " highlight xmlEndTag        ctermfg=114     ctermbg=none    cterm=none
    */

  };

}
