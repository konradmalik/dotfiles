{ lib, ... }:
let
  ytdlFormat = height: "bestvideo[height<=?${toString height}]+bestaudio/best";

  # mpv --profile=720p, and so on
  heightProfiles = lib.listToAttrs (
    map (height: lib.nameValuePair "${toString height}p" { ytdl-format = ytdlFormat height; }) [
      360
      480
      720
      1080
      1440
      2160
    ]
  );

  # the set mpv's own desktop entry claims to handle (upstream etc/mpv.desktop)
  mimeTypes = [
    # video
    "video/3gp"
    "video/3gpp"
    "video/3gpp2"
    "video/avi"
    "video/divx"
    "video/dv"
    "video/fli"
    "video/flv"
    "video/mkv"
    "video/mp2t"
    "video/mp4"
    "video/mp4v-es"
    "video/mpeg"
    "video/msvideo"
    "video/ogg"
    "video/quicktime"
    "video/vnd.avi"
    "video/vnd.divx"
    "video/vnd.mpegurl"
    "video/vnd.rn-realvideo"
    "video/webm"
    "video/x-avi"
    "video/x-flc"
    "video/x-flic"
    "video/x-flv"
    "video/x-m4v"
    "video/x-matroska"
    "video/x-mpeg2"
    "video/x-mpeg3"
    "video/x-ms-afs"
    "video/x-ms-asf"
    "video/x-ms-wmv"
    "video/x-ms-wmx"
    "video/x-ms-wvxvideo"
    "video/x-msvideo"
    "video/x-ogm"
    "video/x-ogm+ogg"
    "video/x-theora"
    "video/x-theora+ogg"

    # audio
    "audio/3gpp"
    "audio/3gpp2"
    "audio/AMR"
    "audio/aac"
    "audio/ac3"
    "audio/aiff"
    "audio/amr-wb"
    "audio/dv"
    "audio/eac3"
    "audio/flac"
    "audio/m3u"
    "audio/m4a"
    "audio/mp1"
    "audio/mp2"
    "audio/mp3"
    "audio/mp4"
    "audio/mpeg"
    "audio/mpeg2"
    "audio/mpeg3"
    "audio/mpegurl"
    "audio/mpg"
    "audio/musepack"
    "audio/ogg"
    "audio/opus"
    "audio/rn-mpeg"
    "audio/scpls"
    "audio/vnd.dolby.heaac.1"
    "audio/vnd.dolby.heaac.2"
    "audio/vnd.dts"
    "audio/vnd.dts.hd"
    "audio/vnd.rn-realaudio"
    "audio/vnd.wave"
    "audio/vorbis"
    "audio/wav"
    "audio/webm"
    "audio/x-aac"
    "audio/x-adpcm"
    "audio/x-aiff"
    "audio/x-ape"
    "audio/x-m4a"
    "audio/x-matroska"
    "audio/x-mp1"
    "audio/x-mp2"
    "audio/x-mp3"
    "audio/x-mpegurl"
    "audio/x-mpg"
    "audio/x-ms-asf"
    "audio/x-ms-wma"
    "audio/x-musepack"
    "audio/x-pls"
    "audio/x-pn-au"
    "audio/x-pn-realaudio"
    "audio/x-pn-wav"
    "audio/x-pn-windows-pcm"
    "audio/x-realaudio"
    "audio/x-scpls"
    "audio/x-shorten"
    "audio/x-tta"
    "audio/x-vorbis"
    "audio/x-vorbis+ogg"
    "audio/x-wav"
    "audio/x-wavpack"

    # containers, playlists and streams
    "application/mxf"
    "application/ogg"
    "application/sdp"
    "application/smil"
    "application/streamingmedia"
    "application/vnd.apple.mpegurl"
    "application/vnd.ms-asf"
    "application/vnd.rn-realmedia"
    "application/vnd.rn-realmedia-vbr"
    "application/x-cue"
    "application/x-extension-m4a"
    "application/x-extension-mp4"
    "application/x-matroska"
    "application/x-mpegurl"
    "application/x-ogg"
    "application/x-ogm"
    "application/x-ogm-audio"
    "application/x-ogm-video"
    "application/x-shorten"
    "application/x-smil"
    "application/x-streamingmedia"
  ];
in
{
  xdg.mimeApps.defaultApplications = lib.genAttrs mimeTypes (_: [ "mpv.desktop" ]);

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      loop-playlist = "inf";
      # mpv builtin profile for cheap playback
      profile = lib.mkDefault "fast";
      sub-auto = "fuzzy";
      sub-bold = "yes";
      video-sync = "display-resample";
      # a profile cannot set this: 'profile=' applies where it appears in the
      # config, and home-manager writes the options sorted, so 'ytdl-format'
      # always lands after it
      ytdl-format = ytdlFormat 1080;
    };
    profiles = heightProfiles // {
      "hq" = {
        # 'scale' comes from high-quality, 'cscale' does not
        profile = "high-quality";
        cscale = "ewa_lanczossharp";
        interpolation = true;
        tscale = "oversample";
      };
      "4k" = {
        profile = "2160p";
      };
      # whatever the source has, no cap
      "best" = {
        ytdl-format = "bestvideo+bestaudio/best";
      };
      # no window, useful for music links
      "audio" = {
        ytdl-format = "bestaudio/best";
        video = false;
      };
      # for hosts without hardware av1 decoding
      "no-av1" = {
        ytdl-format = "bestvideo[vcodec!*=av01]+bestaudio/best";
      };
    };
  };
}
