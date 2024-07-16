{
  config,
  pkgs,
  lib,
  ...
}:
{
  xdg.mimeApps.defaultApplications = {
    "video/flv" = [ "mpv.desktop" ];
    "video/mp2t" = [ "mpv.desktop" ];
    "video/mp4" = [ "mpv.desktop" ];
    "video/mp4v-es" = [ "mpv.desktop" ];
    "video/mpeg" = [ "mpv.desktop" ];
    "video/msvideo" = [ "mpv.desktop" ];
    "video/ogg" = [ "mpv.desktop" ];
    "video/quicktime" = [ "mpv.desktop" ];
    "video/vivo" = [ "mpv.desktop" ];
    "video/vnd.divx" = [ "mpv.desktop" ];
    "video/vnd.rn-realvideo" = [ "mpv.desktop" ];
    "video/vnd.vivo" = [ "mpv.desktop" ];
    "video/webm" = [ "mpv.desktop" ];
    "video/x-anim" = [ "mpv.desktop" ];
    "video/x-avi" = [ "mpv.desktop" ];
    "video/x-flc" = [ "mpv.desktop" ];
    "video/x-fli" = [ "mpv.desktop" ];
    "video/x-flic" = [ "mpv.desktop" ];
    "video/x-flv" = [ "mpv.desktop" ];
    "video/x-m4v" = [ "mpv.desktop" ];
    "video/x-matroska" = [ "mpv.desktop" ];
    "video/x-mpeg" = [ "mpv.desktop" ];
    "video/x-ms-asf" = [ "mpv.desktop" ];
    "video/x-ms-asx" = [ "mpv.desktop" ];
    "video/x-ms-wm" = [ "mpv.desktop" ];
    "video/x-ms-wmv" = [ "mpv.desktop" ];
    "video/x-ms-wmx" = [ "mpv.desktop" ];
    "video/x-ms-wvx" = [ "mpv.desktop" ];
    "video/x-msvideo" = [ "mpv.desktop" ];
    "video/x-nsv" = [ "mpv.desktop" ];
    "video/x-ogm+ogg" = [ "mpv.desktop" ];
    "video/x-theora+ogg" = [ "mpv.desktop" ];
  };
  programs.mpv = {
    enable = true;
    package = pkgs.mpv-unwrapped.wrapper {
      mpv = pkgs.mpv-unwrapped;
      youtubeSupport = true;
    };
    config = {
      profile = lib.mkDefault "fast";
      hwdec = "auto";
      video-sync = "display-resample";
      sub-auto = "fuzzy";
      sub-font = config.fontProfiles.regular.family;
      sub-bold = "yes";
      ytdl-format = "bestvideo+bestaudio";
    };
    profiles = {
      "hq" = {
        profile = "gpu-hq";
        scale = "ewa_lanczossharp";
        cscale = "ewa_lanczossharp";
        interpolation = true;
        tscale = "oversample";
      };
      "fast" = {
        profile = "1080p";
      };
      "1080p" = {
        ytdl-format = "bestvideo[height<=?1080]+bestaudio/best";
      };
      "720p" = {
        ytdl-format = "bestvideo[height<=?720]+bestaudio/best";
      };
    };
  };
}
