{ config, ... }:
{
  imports = [
    ./common/presets/nixos.nix
    ./common/optional/desktop/hyprland
  ];

  konrad.fontProfiles.enable = true;
  konrad.programs.ssh-egress.enable = true;
  konrad.programs.alacritty = {
    enable = true;
    fontSize = 13.0;
  };

  # dynamic output profiles
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    profiles = {
      laptop = {
        outputs = [
          {
            criteria = "eDP-1";
            mode = "3840x2160@59.997Hz";
            position = "0,0";
            scale = 2.0;
            status = "enable";
            transform = "normal";
          }
        ];
      };
      clamshell = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "HDMI-A-1";
            mode = "3440x1440@29.993Hz";
            position = "0,0";
            scale = 1.0;
            status = "enable";
            transform = "normal";
          }
        ];
      };
    };
  };
}
