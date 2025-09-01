{
  pkgs,
  lib,
  config,
  ...
}:

let
  c = config.colorscheme.palette;

  pactl = "${pkgs.pulseaudio}/bin/pactl";
  pgrep = "${pkgs.procps}/bin/pgrep";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";

  isLocked = "${pgrep} -x swaylock";
  actionLock = "swaylock -S --daemonize";

  lockTime = 4 * 60;

  mkEvent = time: start: resume: ''
    timeout ${toString (lockTime + time)} '${start}' ${
      lib.optionalString (resume != null) "resume '${resume}'"
    }
    timeout ${toString time} '${isLocked} && ${start}' ${
      lib.optionalString (resume != null) "resume '${isLocked} && ${resume}'"
    }
  '';
in
{
  wayland.windowManager.hyprland.settings.exec-once = [ "swayidle -w" ];

  xdg.configFile."swayidle/config".text = ''
    timeout ${toString lockTime} '${actionLock}'
  ''
  +
    # After 10 seconds of locked, mute mic
    (mkEvent 10 "${pactl} set-source-mute @DEFAULT_SOURCE@ yes"
      "${pactl} set-source-mute @DEFAULT_SOURCE@ no"
    )
  +
    # Hyprland - Turn off screen (DPMS)
    lib.optionalString config.wayland.windowManager.hyprland.enable (
      mkEvent 40 "${hyprctl} dispatch dpms off" "${hyprctl} dispatch dpms on"
    );

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      effect-blur = "20x3";
      fade-in = 0.1;

      font = config.fontProfiles.regular.family;
      font-size = config.fontProfiles.regular.size;

      line-uses-inside = true;
      disable-caps-lock-text = true;
      indicator-caps-lock = true;
      indicator-radius = 40;
      indicator-idle-visible = true;
      indicator-y-position = 1000;

      ring-color = "#${c.base02}";
      inside-wrong-color = "#${c.base08}";
      ring-wrong-color = "#${c.base08}";
      key-hl-color = "#${c.base0B}";
      bs-hl-color = "#${c.base08}";
      ring-ver-color = "#${c.base09}";
      inside-ver-color = "#${c.base09}";
      inside-color = "#${c.base01}";
      text-color = "#${c.base07}";
      text-clear-color = "#${c.base01}";
      text-ver-color = "#${c.base01}";
      text-wrong-color = "#${c.base01}";
      text-caps-lock-color = "#${c.base07}";
      inside-clear-color = "#${c.base0C}";
      ring-clear-color = "#${c.base0C}";
      inside-caps-lock-color = "#${c.base09}";
      ring-caps-lock-color = "#${c.base02}";
      separator-color = "#${c.base02}";
    };
  };
}
