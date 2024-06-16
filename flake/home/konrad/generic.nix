{
  imports = [
    # nix settings applied via home-manager
    ../../hosts/common/modules/nix/linux.nix
    ./common/nixos.nix
  ];
}
