{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.steam;
in
{

  options.myOS.programs.steam = with lib; {

    enable = mkEnableOption "steam";

    configure = mkOption {
      type = types.nullOr types.bool;
      default = cfg.enable;
    };

  };

  config = lib.mkIf cfg.configure {

    # Steam creates a .desktop entry for every installed game under
    # ~/.local/share/applications and offers no setting to disable it. Stamp
    # NoDisplay=true onto those shortcuts so they stay out of launchers (fuzzel,
    # etc.). Re-applied on every switch, since Steam regenerates them.
    home.activation.hideSteamShortcuts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      for f in "$HOME/.local/share/applications"/*.desktop; do
        [ -e "$f" ] || continue
        if ${pkgs.gnugrep}/bin/grep -q 'steam://rungameid' "$f" \
          && ! ${pkgs.gnugrep}/bin/grep -q '^NoDisplay=' "$f"; then
          run ${pkgs.gnused}/bin/sed -i '/^\[Desktop Entry\]$/a NoDisplay=true' "$f"
        fi
      done
    '';

  };

}
