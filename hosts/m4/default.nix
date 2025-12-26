{
  imports = [ ../common/profiles/macbook.nix ];

  nixpkgs.system = "aarch64-darwin";

  networking.hostName = "m4";
}
