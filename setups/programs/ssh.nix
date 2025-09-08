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

      matchBlocks = {

        "home-lab" = lib.hm.dag.entryAfter [ "*" ] {
          hostname = "home-lab";
          user = "elias";
          port = 22;
          # ignoreUnknown = "UseKeychain";
          addKeysToAgent = "yes";
        };

        "*" = {
          identityAgent = onePassPath;
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };

      };

    };

  };

}
