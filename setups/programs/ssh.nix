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

    # Headless hosts have no keyring agent, so run one as a user service and
    # cache passphrase-protected keys in it on first use.
    agent.enable = mkEnableOption "ssh-agent user service";

  };

  config = lib.mkIf cfg.enable {

    services.ssh-agent.enable = cfg.agent.enable;

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

        "gitlab.com" = lib.hm.dag.entryAfter [ "*" ] {
          HostName = "gitlab.com";
          User = "git";
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
          AddKeysToAgent = if cfg.agent.enable then "yes" else "no";
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
