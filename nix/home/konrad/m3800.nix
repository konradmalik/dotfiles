{ config, ... }:
{
  imports = [
    ./common/presets/nixos.nix
    ./common/optional/desktop/hyprland
  ];

  fontProfiles.enable = true;
  konrad.programs.gpg.enable = true;
  konrad.programs.ssh-egress.enable = true;
  konrad.programs.bitwarden.enable = true;
  konrad.programs.alacritty.enable = true;

  konrad.programs.syncthing = {
    enable = true;
    install = true;
  };

  monitors = [
    {
      name = "eDP-1";
      enabled = false;
      width = 3840;
      height = 2160;
      isPrimary = true;
      refreshRate = 59.997;
      scale = 2;
      x = 0;
    }
    {
      name = "HDMI-A-1";
      enabled = true;
      width = 3440;
      height = 1440;
      isPrimary = true;
      refreshRate = 29.993;
      scale = 1;
      x = 0;
    }
  ];
}
