{ config, ... }:
{
  imports = [
    ./common/presets/nixos.nix
  ];

  services.syncthing.enable = true;
}
