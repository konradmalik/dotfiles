{ hostPkgs, guestPkgs }:
{ config, lib, modulesPath, ... }:
let
  users = builtins.attrNames config.users.users;
  nonRootUsers = builtins.filter (n: n != "root") users;
  user = builtins.elemAt nonRootUsers 0;
in
{
  imports = [
    "${modulesPath}/profiles/macos-builder.nix"
  ];

  nixpkgs.pkgs = guestPkgs;

  virtualisation = {
    host.pkgs = hostPkgs;
    diskImage = "./VMs/darwin-builder.qcow2";
  };

  # not needed for > 22.11
  services.getty.autologinUser = user;

  system = {
    # don't change name here, it's hardcoded in script name in macos-builder.nix
    name = "nixos";
    stateVersion = lib.mkDefault "22.11";
  };
}
