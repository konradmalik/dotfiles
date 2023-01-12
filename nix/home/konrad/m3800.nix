{ config, ... }:
{
  imports = [
    ./common/presets/nixos.nix
  ];

  konrad.programs.desktop.enable = true;
  konrad.programs.ssh-egress.enable = true;
  konrad.programs.alacritty.fontSize = 13.0;
}
