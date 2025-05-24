{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myOS.programs.mpv;
  mpvConfPath = "${config.home.homeDirectory}/.var/app/io.mpv.Mpv/config/mpv/mpv.conf";
  mpvConf = builtins.toFile "mpv.conf" ''
    # General
    keep-open="yes"
    autofit="65%"
    cursor-autohide="500"

    # Audio
    volume="100"
    volume-max="100"

    # Subs
    demuxer-mkv-subtitle-preroll="yes"
    sub-ass-use-video-data="none"
    sub-fix-timing="yes"
    sub-font="Open Sans Semibold"
    # sub-bold="yes"
    sub-font-size="54"
    sub-border-size="2.5"
    sub-margin-y="28"
    sub-color="#ffffffff"

    # Audio & Subs Prop
    alang="ja,jp,jpn,en,eng,de,deu,ger"
    slang="en,eng,de,deu,ger"

    #Screenshot
    screenshot-format="png"
    screenshot-high-bit-depth="no"
    screenshot-png-compression="1"
    screenshot-jpeg-quality="95"
    screenshot-template="%f-%wH.%wM.%wS.%wT-#%#00n"

    # Deband
    deband="no"
    deband-iterations="4"
    deband-threshold="50"
    deband-range="16"
    deband-grain="0"

    # Resizer
    scale="ewa_lanczossharp"
    dscale="catmull_rom"
    cscale="sinc"
    cscale-window="blackman"
    cscale-radius="3"

    [EraiRaws]
    profile-cond=string.match(get("filename"), "%[Erai%-raws%]")
    deband="yes"

    [HorribleSubs]
    profile-cond=string.match(get("filename"), "%[HorribleSubs%]")
    deband="yes"

    [SubsPlease]
    profile-cond=string.match(get("filename"), "%[SubsPlease%]")
    deband="yes"

    [Interpolation]
    profile-cond=p["container_fps"] <= 24
    blend-subtitles="yes"
    video-sync="display-resample"
    interpolation="yes"
    tscale="gaussian"
    tscale-window="sphinx"
    tscale-radius="1.05"
    tscale-clamp="0.0"
  '';
in
{

  options.myOS.programs.mpv = with lib; {

    enable = mkEnableOption "mpv";

    configure = mkOption {
      type = types.nullOr types.bool;
      default = cfg.enable;
    };

  };

  config = {

    home.packages = lib.mkIf cfg.enable (
      with pkgs;
      [
        mpv # General-purpose media player, fork of MPlayer and mplayer2
      ]
    );

    programs.mpv.enable = cfg.enable;

    home.activation.copyMpvConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $(dirname "${mpvConfPath}")
      cp -f ${mpvConf} "${mpvConfPath}"
      chmod 444 "${mpvConfPath}"
    '';

  };

}
