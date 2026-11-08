{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myOS.programs.pi;
  agents = config.myOS.programs.agents;
  meridian = config.myOS.programs.meridian;

  # Pi rewrites settings.json from /model and /settings, so it stays a real file. Activation fills in these
  # defaults where it lacks them, so a choice made in Pi sticks.
  defaultSettings = {
    defaultProvider = "meridian";
    defaultModel = "claude-opus-5-5";
    defaultThinkingLevel = "high";
    theme = "catppuccin-latte/catppuccin-mocha";
    # Pi has no verbosity setting; these come closest to OpenCode's low verbosity. Tool output starts
    # collapsed already.
    hideThinkingBlock = true;
    collapseChangelog = true;
  };

  # Replaced whole at every activation, so each machine runs the same packages. Exact versions stay pinned:
  # Pi installs them into ~/.pi/agent/npm at startup and never updates them.
  packages = [
    "npm:pi-catppuccin@0.1.0"
    "npm:pi-footer@0.5.1"
    "npm:pi-permission-system@0.8.0"
    "npm:pi-subagents@0.87.0"
    "npm:pi-web-access@0.47.0"
  ];

  mergeSettings = pkgs.writeShellScript "pi-merge-settings" ''
    set -eu
    settings="$HOME/.pi/agent/settings.json"
    mkdir -p "$(dirname "$settings")"
    [ -e "$settings" ] || echo '{}' > "$settings"
    tmp=$(mktemp "$settings.XXXXXX")
    trap 'rm -f "$tmp"' EXIT
    ${lib.getExe pkgs.jq} \
      --argjson defaults ${lib.escapeShellArg (builtins.toJSON defaultSettings)} \
      --argjson packages ${lib.escapeShellArg (builtins.toJSON packages)} \
      '$defaults * . | .packages = $packages' "$settings" > "$tmp"
    mv "$tmp" "$settings"
  '';

  # Meridian forwards the effort but drops `budget_tokens`, so every model uses adaptive thinking and
  # Pi's levels map to Anthropic efforts. Low to high map by name; xhigh and max need an entry.
  efforts = {
    xhigh = "xhigh";
    max = "max";
  };

  models = {
    providers.meridian = {
      baseUrl = "http://127.0.0.1:${toString meridian.port}";
      api = "anthropic-messages";
      # Meridian holds the Claude login; Pi only needs some key to list the models.
      apiKey = "meridian";
      headers.x-meridian-agent = "pi";
      compat = {
        forceAdaptiveThinking = true;
        # Meridian keys its sessions on this header.
        sendSessionAffinityHeaders = true;
      };
      models = [
        {
          id = "claude-opus-5-5";
          name = "Claude Opus 5.5";
          reasoning = true;
          input = [
            "text"
            "image"
          ];
          contextWindow = 1000000;
          maxTokens = 128000;
          # Adaptive thinking only, as in Pi's own anthropic catalog.
          thinkingLevelMap = efforts // {
            off = null;
            minimal = null;
          };
          compat.supportsTemperature = false;
        }
        {
          id = "claude-fable-5-1";
          name = "Claude Fable 5.1";
          reasoning = true;
          input = [
            "text"
            "image"
          ];
          contextWindow = 1000000;
          maxTokens = 128000;
          thinkingLevelMap = efforts;
        }
        {
          id = "claude-sonnet-5-5";
          name = "Claude Sonnet 5.5";
          reasoning = true;
          input = [
            "text"
            "image"
          ];
          contextWindow = 200000;
          maxTokens = 128000;
          thinkingLevelMap = efforts;
          compat.supportsTemperature = false;
        }
        {
          id = "claude-haiku-4-5";
          name = "Claude Haiku 4.5";
          reasoning = true;
          input = [
            "text"
            "image"
          ];
          contextWindow = 200000;
          maxTokens = 64000;
          thinkingLevelMap = efforts;
        }
      ];
    };
  };

  # Fedora Atomic links /home to /var/home, and the permission system compares paths without resolving
  # links, so each home path is listed in both forms.
  homes = lib.unique [
    config.home.homeDirectory
    (lib.removePrefix "/var" config.home.homeDirectory)
  ];
  externalDirectories =
    lib.concatMap (home: [
      "${home}/.agents"
      "${home}/.dotfiles"
      "${home}/git"
      "${home}/PycharmProjects"
    ]) homes
    ++ [
      "/nix/store"
      "/tmp"
    ];

  # The same policy as OpenCode's permissions.json. Skills load by reading SKILL.md here, so those reads
  # stay open.
  permissions = {
    defaultPolicy = {
      tools = "ask";
      bash = "allow";
      mcp = "ask";
      skills = "allow";
      special = "ask";
    };
    tools = [
      { read = "allow"; }
      { edit = "allow"; }
      { write = "allow"; }
      { grep = "allow"; }
      { find = "allow"; }
      { ls = "allow"; }
      { "read:*.env" = "deny"; }
      { "read:*.env.*" = "deny"; }
      { "read:*.env.example" = "allow"; }
      # pi-web-access
      { web_search = "allow"; }
      { fetch_content = "allow"; }
      { get_search_content = "allow"; }
      { source_check = "allow"; }
      # pi-subagents
      { "subagent*" = "allow"; }
      { bg_wait = "allow"; }
      { contact_supervisor = "allow"; }
      { structured_output = "allow"; }
      { watchdog_diff = "allow"; }
    ];
    special = lib.concatMap (dir: [
      { "external_directory:${dir}" = "allow"; }
      { "external_directory:${dir}/*" = "allow"; }
    ]) externalDirectories;
  };

  # The last matching rule wins in file order, and builtins.toJSON sorts keys, so the rule lists are
  # written out by hand.
  rulesJSON =
    rules:
    "{${
      lib.concatMapStringsSep "," (
        rule:
        lib.concatStrings (
          lib.mapAttrsToList (key: value: "${builtins.toJSON key}:${builtins.toJSON value}") rule
        )
      ) rules
    }}";

  herdrExtension = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/herdrdev/herdr/v${pkgs.herdr.version}/src/integration/assets/pi/herdr-agent-state.ts";
    hash = "sha256-LFJy1zK0dbv5GgJyA7H5jSX+Q9LBQCUwpEKyiK6soeQ=";
  };
in
{

  options.myOS.programs.pi = with lib; {

    enable = mkEnableOption "Pi configuration (the binary stays with Pi's own installer in ~/.pi/agent)";

    extensions.herdr.enable = mkEnableOption "the herdr Pi extension";

  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = agents.enable;
        message = "myOS.programs.pi.enable requires myOS.programs.agents.enable.";
      }
      {
        assertion = meridian.enable;
        message = "myOS.programs.pi.enable requires myOS.programs.meridian.enable.";
      }
      {
        assertion = cfg.extensions.herdr.enable -> config.myOS.programs.herdr.enable;
        message = "myOS.programs.pi.extensions.herdr.enable requires myOS.programs.herdr.enable.";
      }
    ];

    # Pi finds ~/.agents/skills itself but reads its global rules only from its own directory.
    # Skills in ~/.pi/agent/skills win name clashes over ~/.agents/skills.
    # Extensions are linked one by one: pi-footer writes its config into the extensions directory.
    home.file = {
      ".pi/agent/AGENTS.md".source = agents.rules;
      ".pi/agent/models.json".text = builtins.toJSON models;
      ".pi/agent/pi-permissions.jsonc".text = ''
        {"defaultPolicy":${builtins.toJSON permissions.defaultPolicy},"tools":${rulesJSON permissions.tools},"special":${rulesJSON permissions.special}}
      '';
      ".pi/agent/extensions/agents-local.ts".source = ./extensions/agents-local.ts;
      ".pi/agent/extensions/loaded-skills.ts".source = ./extensions/loaded-skills.ts;
    }
    // lib.optionalAttrs cfg.extensions.herdr.enable {
      ".pi/agent/extensions/herdr-agent-state.ts".source = herdrExtension;
    }
    // lib.mapAttrs' (
      name: source: lib.nameValuePair ".pi/agent/skills/${name}" { inherit source; }
    ) agents.skillOverrides;

    home.activation.piSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${mergeSettings}
    '';

  };

}
