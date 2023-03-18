{ hostPkgs, guestPkgs }:
{ config, lib, modulesPath, ... }:
let
  # not sure why, but docker panics at cores more than 1 on macos...
  cores = 1;
  diskSize = 40 * 1024;
  memorySize = 4 * 1024;
  keys = config.sshKeys.personal.keys;
in
{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"

    ./../../../hosts/common/global/docker.nix
    ./../../../hosts/common/global/openssh.nix
    ./../../../modules/home-manager/ssh-keys.nix
    ./../../../home/konrad/common/global/ssh-keys.nix
  ];

  nixpkgs.pkgs = guestPkgs;

  documentation.enable = false;

  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  users.users.root.openssh.authorizedKeys.keys = keys;
  users.extraUsers.root.password = "";
  users.mutableUsers = false;
  services.openssh.permitRootLogin = "yes";

  services.getty.autologinUser = "root";

  system = {
    name = lib.mkDefault "darwin-docker";
    stateVersion = lib.mkDefault "22.11";
  };

  virtualisation = {
    inherit cores diskSize memorySize;

    host.pkgs = hostPkgs;
    diskImage = "./VMs/${config.system.name}.qcow2";

    graphics = false;

    forwardPorts = [
      { from = "host"; guest.port = 22; host.port = 2376; }
    ];
  };
}
