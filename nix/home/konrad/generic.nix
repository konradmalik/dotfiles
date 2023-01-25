{ config, pkgs, ... }:
{
  imports = [
    ../../hosts/common/global/nix/shared.nix
    ./common/presets/generic.nix
  ];

  home.packages = with pkgs; [ remove-old-snaps ];
}
