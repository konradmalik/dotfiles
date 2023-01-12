{ config, ... }:
{
  imports = [
    ../../hosts/common/global/nix/shared.nix
    ./common/presets/generic.nix
  ];
}
