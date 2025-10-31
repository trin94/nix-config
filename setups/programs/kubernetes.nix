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
            skin = "dracula";
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

      skins.dracula = {
        k9s = {
          body = {
            fgColor = "#f8f8f2";
            bgColor = "#282a36";
            logoColor = "#bd93f9";
          };
          prompt = {
            fgColor = "#f8f8f2";
            bgColor = "#282a36";
            suggestColor = "#bd93f9";
          };
          info = {
            fgColor = "#ff79c6";
            sectionColor = "#f8f8f2";
          };
          dialog = {
            fgColor = "#f8f8f2";
            bgColor = "#282a36";
            buttonFgColor = "#f8f8f2";
            buttonBgColor = "#bd93f9";
            buttonFocusFgColor = "#f1fa8c";
            buttonFocusBgColor = "#ff79c6";
            labelFgColor = "#ffb86c";
            fieldFgColor = "#f8f8f2";
          };
          frame = {
            border = {
              fgColor = "#44475a";
              focusColor = "#44475a";
            };
            menu = {
              fgColor = "#f8f8f2";
              keyColor = "#ff79c6";
              numKeyColor = "#ff79c6";
            };
            crumbs = {
              fgColor = "#f8f8f2";
              bgColor = "#44475a";
              activeColor = "#44475a";
            };
            status = {
              newColor = "#8be9fd";
              modifyColor = "#bd93f9";
              addColor = "#50fa7b";
              errorColor = "#ff5555";
              highlightColor = "#ffb86c";
              killColor = "#6272a4";
              completedColor = "#6272a4";
            };
            title = {
              fgColor = "#f8f8f2";
              bgColor = "#44475a";
              highlightColor = "#ffb86c";
              counterColor = "#bd93f9";
              filterColor = "#ff79c6";
            };
          };
          views = {
            charts = {
              bgColor = "default";
              defaultDialColors = [
                "#bd93f9"
                "#ff5555"
              ];
              defaultChartColors = [
                "#bd93f9"
                "#ff5555"
              ];
            };
            table = {
              fgColor = "#f8f8f2";
              bgColor = "#282a36";
              header = {
                fgColor = "#f8f8f2";
                bgColor = "#282a36";
                sorterColor = "#8be9fd";
              };
            };
            xray = {
              fgColor = "#f8f8f2";
              bgColor = "#282a36";
              cursorColor = "#44475a";
              graphicColor = "#bd93f9";
              showIcons = false;
            };
            yaml = {
              keyColor = "#ff79c6";
              colonColor = "#bd93f9";
              valueColor = "#f8f8f2";
            };
            logs = {
              fgColor = "#f8f8f2";
              bgColor = "#282a36";
              indicator = {
                fgColor = "#f8f8f2";
                bgColor = "#bd93f9";
                toggleOnColor = "#50fa7b";
                toggleOffColor = "#8be9fd";
              };
            };
          };
        };
      };

    };

  };
}
