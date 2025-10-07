{ inputs, ... }:
{
  imports = [
    # nix settings applied via home-manager
    ../../hosts/common/modules/nix/linux.nix

    # stylix because without nixos it's not applied automatically
    inputs.stylix.homeModules.stylix
    ../../hosts/common/modules/stylix.nix

    ./common/nixos.nix
  ];
}
