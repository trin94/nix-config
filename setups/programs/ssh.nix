{
  config,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.ssh;
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

        "codereview.qt-project.org" = lib.hm.dag.entryAfter [ "*" ] {
          HostName = "codereview.qt-project.org";
          User = "trin94";
          Port = 29418;
          PreferredAuthentications = "publickey";
          IdentityFile = "~/.ssh/id_ed25519";
        };

        "*" = {
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
