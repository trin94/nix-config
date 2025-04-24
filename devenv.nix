{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };
in

{
  dotenv.enable = true;

  # See full reference at https://devenv.sh/reference/options/

  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = with pkgs-unstable; [
    biome
    taplo
    yamlfmt
    mdformat
  ];

  # https://devenv.sh/scripts/
  # scripts.hello.exec = '''';

  enterShell = '''';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Skipping tests"
  '';

  # https://devenv.sh/git-hooks/
  git-hooks = {

    hooks = {

      end-of-file-fixer = {
        enable = true;
        name = "fix end of file";
      };

      trim-trailing-whitespace = {
        enable = true;
        name = "fix trailing whitespace";
        after = [ "end-of-file-fixer" ];
      };

      biome-check = {
        enable = true;
        name = "fmt json";
        after = [ "trim-trailing-whitespace" ];
        entry = "biome";
        files = "\\.(jsonc?)$";
        args = [
          "check"
          "--bracket-spacing=true"
          "--indent-style=space"
          "--indent-width=4"
          "--line-ending=lf"
          "--line-width=120"
        ];
      };

      mdformat = {
        enable = true;
        name = "fmt md";
        after = [ "biome-check" ];
        entry = "mdformat";
        args = [
          "--number"
          "--wrap"
          "keep"
          "--end-of-line"
          "lf"
        ];
      };

      nixfmt-rfc-style = {
        enable = true;
        name = "fmt nix";
        after = [ "mdformat" ];
      };

      taplo-format = {
        enable = true;
        name = "fmt toml";
        after = [ "nixfmt-rfc-style" ];
        entry = "taplo";
        args = [
          "format"
          "--option"
          "align_comments=true"
          "--option"
          "allowed_blank_lines=1"
          "--option"
          "array_auto_collapse=false"
          "--option"
          "indent_string=    "
        ];
      };

      yamlfmt = {
        enable = true;
        name = "fmt yml";
        after = [ "taplo-format" ];
        entry = "yamlfmt";
        args = [
          "-formatter"
          "line_ending=lf"
          "-formatter"
          "retain_line_breaks_single=true"
          "-formatter"
          "scan_folded_as_literal=true"
        ];
      };

    };
  };

}
