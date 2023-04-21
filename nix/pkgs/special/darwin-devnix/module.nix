{ hostPkgs, guestPkgs }:
{ config, lib, modulesPath, ... }:
let
  name = "devnix";
  cores = 4;
  diskSize = 40 * 1024;
  memorySize = 8 * 1024;
in
{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
    "${modulesPath}/profiles/qemu-guest.nix"

    ./../../../hosts/common/presets/nixos.nix
  ];

  nixpkgs.pkgs = guestPkgs;

  networking.hostName = name;

  users.extraUsers.root.password = "";
  services.openssh.permitRootLogin = "yes";
  services.getty.autologinUser = "root";

  system.name = "darwin-${name}";

  virtualisation = {
    inherit cores diskSize memorySize;

    host.pkgs = hostPkgs;
    diskImage = "./VMs/${config.system.name}.qcow2";

    graphics = false;
  };
}
