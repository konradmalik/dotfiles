{
  imports = [ ./../common/darwin.nix ];

  nixpkgs.system = "x86_64-darwin";

  networking.hostName = "mbp13";

  stylix.fonts.sizes.terminal = 15;
}
