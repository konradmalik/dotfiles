{
  imports = [ ../common/profiles/macbook.nix ];

  nixpkgs.system = "x86_64-darwin";

  networking.hostName = "mbp13";

  system.stateVersion = 4;
}
