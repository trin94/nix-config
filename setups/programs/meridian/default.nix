{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myOS.programs.meridian;
  plugins = inputs.meridian.legacyPackages.${pkgs.stdenv.hostPlatform.system}.meridianPlugins;
  piIdentity = pkgs.writeTextDir "lib/pi-identity.mjs" (builtins.readFile ./pi-identity.mjs);
in
{

  imports = [ inputs.meridian.homeModules.default ];

  options.myOS.programs.meridian = with lib; {

    enable = mkEnableOption "a standalone Meridian proxy for clients other than OpenCode";

    port = mkOption {
      type = types.port;
      # opencode-with-claude starts its own Meridian on 3456. If it gets there first, a standalone
      # Meridian on that port exits 0 and Restart=on-failure never brings it back.
      default = 3457;
      readOnly = true;
      description = "Port the service listens on, for clients to point their Anthropic base URL at.";
    };

  };

  config = lib.mkIf cfg.enable {

    services.meridian = {
      enable = true;
      settings = {
        inherit (cfg) port;
        pluginConfig = [
          { path = plugins.pi-scrub.path; }
          { path = "${piIdentity}/lib/pi-identity.mjs"; }
        ];
      };
      environment.MERIDIAN_NO_UPDATE_CHECK = "1";
    };

    # Two Meridians refreshing the same ~/.claude/.credentials.json can rotate each other's refresh token
    # away. The always-on service owns refreshing; the one opencode-with-claude starts in-process only reads.
    home.sessionVariables.MERIDIAN_CREDENTIALS_READONLY = "1";

  };

}
