{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.graphical.mpv;
in
{

  options.myOS.graphical.mpv = with lib; {

    enable = mkEnableOption "mpv";

  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      mpv # General-purpose media player, fork of MPlayer and mplayer2
    ];

    programs.mpv = {
      enable = true;

      config = {

        # General
        "keep-open" = "yes";
        "autofit" = "65%";
        "cursor-autohide" = 500;

        # Audio
        "volume" = 100;
        "volume-max" = 100;

        # Subs
        "demuxer-mkv-subtitle-preroll" = "yes";
        "sub-ass-vsfilter-blur-compat" = "no";
        "sub-fix-timing" = "yes";
        "sub-font" = "Open Sans Semibold";
        "sub-bold" = "yes";
        "sub-font-size" = 54;
        "sub-border-size" = 2.5;
        "sub-margin-y" = 28;
        "sub-color" = "#ffffffff";

        # Audio & Subs Prop
        "alang" = "ja,jp,jpn,en,eng,de,deu,ger";
        "slang" = "en,eng,de,deu,ger";

        #Screenshot
        "screenshot-format" = "png";
        "screenshot-high-bit-depth" = "no";
        "screenshot-png-compression" = 1;
        "screenshot-jpeg-quality" = 95;
        "screenshot-template" = "%f-%wH.%wM.%wS.%wT-#%#00n";

        # Deband
        "deband" = "no";
        "deband-iterations" = 4;
        "deband-threshold" = 50;
        "deband-range" = 16;
        "deband-grain" = 0;

        # Resizer
        "scale" = "ewa_lanczossharp";
        "dscale" = "catmull_rom";
        "cscale" = "sinc";
        "cscale-window" = "blackman";
        "cscale-radius" = 3;

        # Interpolation
        "blend-subtitles" = "yes";
        "video-sync" = "display-resample";
        "interpolation" = "yes";
        "tscale" = "box";
        "tscale-window" = "sphinx";
        "tscale-radius" = 1.05;
        "tscale-clamp" = 0.0;
      };

      profiles = {

        HorribleSubs = {
          profile-cond = "string.match(p.filename, \"%[1080p%+%]\")~=nil";
          deband = "yes";
        };

        EraiRaws = {
          profile-cond = "string.match(p.filename, \"Erai%-raws\")~=nil";
          deband = "yes";
        };

        SubsPlease = {
          profile-cond = "string.match(p.filename, \"SubsPlease\")~=nil";
          deband = "yes";
        };

      };
    };
  };

}
