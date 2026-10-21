{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.imgdiff;

  # rpm-ostree comes from the Fedora Atomic host
  imgdiff = pkgs.writeShellApplication {
    name = "imgdiff";
    text = ''
      for arg in "$@"; do
        case "$arg" in
          -h | --help) exec ${pkgs.coreutils}/bin/cat ${./help.txt} ;;
        esac
      done
      exec ${lib.getExe pkgs.nushell} ${./imgdiff.nu} "$@"
    '';
  };
in
{

  options.myOS.programs.imgdiff = with lib; {

    enable = mkEnableOption "imgdiff, package changes between Fedora Atomic images";

  };

  config = lib.mkIf cfg.enable {

    home.packages = [
      imgdiff
    ];

    xdg.configFile."fish/completions/imgdiff.fish".source = ./completions.fish;

    # the host keeps only three deployments; saving at every login catches each upgrade before it rotates out
    systemd.user.services.imgdiff-record = {
      Unit.Description = "Save package changes of the local Fedora Atomic deployments";
      Service = {
        Type = "oneshot";
        ExecStart = "${lib.getExe imgdiff} record";
      };
      Install.WantedBy = [ "default.target" ];
    };

  };

}
