{
  config,
  lib,
  ...
}:
let
  cfg = config.myOS.terminal.ssh;
  onePassPath = "~/.1password/agent.sock";
in
{

  options.myOS.terminal.ssh = with lib; {

    enable = mkEnableOption "ssh";

  };

  config = lib.mkIf cfg.enable {

    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host *
            IdentityAgent ${onePassPath}

        Host home-lab
            IgnoreUnknown UseKeychain
            HostName home-lab
            AddKeysToAgent yes
            User elias
            Port 22
      '';
    };

    home.file.".ssh/config" = {
      target = ".ssh/config_source";
      onChange = ''cat ~/.ssh/config_source > ~/.ssh/config && chmod 400 ~/.ssh/config'';
    };
  };

}
