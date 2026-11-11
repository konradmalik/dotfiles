let
  minutes = m: builtins.floor (m * 60);

  dpms = action: "hyprctl dispatch 'hl.dsp.dpms({action = \"${action}\"})'";
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = dpms "on";
        # hypridle (<=0.1.8) recreates all idle notifications when an inhibitor is
        # released while already idled, dropping the pending on-resume. A short
        # logind "idle" inhibit (e.g. udisks mounting ESPs for fwupd-refresh) after
        # dpms off thus leaves the screens off with no way to wake them.
        # Apps inhibit via wayland idle-inhibit or dbus ScreenSaver anyway.
        ignore_systemd_inhibit = true;
      };
      listener = [
        {
          timeout = minutes 5;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = minutes 5.5;
          on-timeout = dpms "off";
          on-resume = dpms "on";
        }
        {
          timeout = minutes 15;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
