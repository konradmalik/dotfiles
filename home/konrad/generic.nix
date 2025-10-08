{ inputs, ... }:
{
  imports = [
    ../../hosts/common/modules/nix/hm.nix

    inputs.stylix.homeModules.stylix
    ../../hosts/common/modules/stylix

    ./common/hm.nix
  ];
}
