{ ... }:
let
  minutes = m: builtins.floor (m * 60);
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = minutes 5;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = minutes 5.5;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = minutes 15;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
