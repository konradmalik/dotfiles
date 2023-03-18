{ hostPkgs, guestPkgs }:
{ config, lib, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/macos-builder.nix"
  ];

  nixpkgs.pkgs = guestPkgs;

  virtualisation = {
    host.pkgs = hostPkgs;
    diskImage = "./VMs/darwin-builder.qcow2";
  };

  system = {
    # don't change name here, it's hardcoded in script name in macos-builder.nix
    name = "nixos";
    stateVersion = lib.mkDefault "22.11";
  };
}
