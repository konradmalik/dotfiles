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
