{
  config,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.ssh;
  onePassPath = "~/.1password/agent.sock";
in
{

  options.myOS.programs.ssh = with lib; {

    enable = mkEnableOption "ssh";

  };

  config = lib.mkIf cfg.enable {

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {

        "home-lab" = lib.hm.dag.entryAfter [ "*" ] {
          HostName = "home-lab";
          User = "elias";
          Port = 22;
          # IgnoreUnknown = "UseKeychain";
          AddKeysToAgent = "yes";
        };

        "*" = {
          IdentityAgent = onePassPath;
          ForwardAgent = false;
          AddKeysToAgent = "no";
          Compression = false;
          ServerAliveInterval = 0;
          ServerAliveCountMax = 3;
          HashKnownHosts = false;
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
        };

      };

    };

  };

}
