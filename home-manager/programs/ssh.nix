{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.ssh;
  onePassPath = "~/.1password/agent.sock";
in
{

  options.myOS.ssh = with lib; {

    enable = mkEnableOption "ssh";

  };

  config = lib.mkIf cfg.enable {

    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host *
            IdentityAgent ${onePassPath}
      '';
    };

    home.file.".ssh/config" = {
      target = ".ssh/config_source";
      onChange = ''cat ~/.ssh/config_source > ~/.ssh/config && chmod 400 ~/.ssh/config'';
    };
  };

}
