{
  imports = [ ../common/profiles/macbook.nix ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "m4";
}
