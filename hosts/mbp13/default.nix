{
  imports = [ ./../common/presets/darwin.nix ];

  nixpkgs.system = "x86_64-darwin";

  networking.hostName = "mbp13";
}
