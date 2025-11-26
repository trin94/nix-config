{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.chromium;
in
{

  options.myOS.programs.chromium = with lib; {

    enable = mkEnableOption "chromium";

    configure = mkOption {
      type = types.nullOr types.bool;
      default = cfg.enable;
    };

  };

  config = {

    home.activation = lib.mkIf cfg.configure {
      chromiumFlags = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p ~/.var/app/org.chromium.Chromium/config
        $DRY_RUN_CMD cat > ~/.var/app/org.chromium.Chromium/config/chromium-flags.conf << 'EOF'
        --disable-features=GlobalShortcutsPortal
        EOF
      '';
    };

  };

}
