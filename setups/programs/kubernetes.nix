{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.kubernetes;
in
{

  options.myOS.programs.kubernetes = with lib; {

    enable = mkEnableOption "kubernetes";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      k9s
      kubernetes-helm-wrapped
      kubectx
      stern
    ];

    programs.k9s = {
      enable = true;

      settings = {
        k9s = {
          ui = {
            enableMouse = false;
            headless = false;
            crumbsless = false;
            noIcons = true;
            logoless = true;
          };
          refreshRate = 2;
          maxConnRetry = 5;
          shellPod = {
            image = "killerAdmin";
            namespace = "default";
            limits = {
              cpu = "100m";
              memory = "100Mi";
            };
            tty = true;
            command = [ "/bin/sh" ];
          };
        };
      };

      aliases = {
        dp = "deployments";
        po = "pods";
        svc = "services";
        cm = "configmaps";
        sec = "secrets";
        ns = "namespaces";
        no = "nodes";
        ing = "ingress";
      };

      plugins = {
        stern = {
          shortCut = "Ctrl-L";
          description = "Logs <Stern>";
          scopes = [ "pods" ];
          command = "stern";
          background = false;
          args = [
            "--tail"
            "50"
            "$NAME"
            "-n"
            "$NAMESPACE"
          ];
        };
      };

    };

  };
}
