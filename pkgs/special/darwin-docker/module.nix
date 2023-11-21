{ hostPkgs, guestPkgs }:
{ config, lib, modulesPath, ... }:
let
  cores = 4;
  diskSize = 40 * 1024;
  memorySize = 8 * 1024;
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

  networking = {
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    firewall.enable = false;
  };

  users.users.root = {
    openssh.authorizedKeys.keys = keys;
    password = "";
  };

  users.mutableUsers = false;
  services.openssh.settings.PermitRootLogin = "yes";

  services.getty.autologinUser = "root";

  system = {
    name = lib.mkDefault "darwin-docker";
    stateVersion = lib.mkDefault "24.05";
  };

  virtualisation = {
    inherit cores diskSize memorySize;

    host.pkgs = hostPkgs;
    diskImage = "./VMs/${config.system.name}.qcow2";

    graphics = false;

    forwardPorts = [
      # ssh
      { from = "host"; guest.port = 22; host.port = 2376; }
      # k3s
      { from = "host"; guest.port = 6443; host.port = 6443; }
    ];
    # if this is not enabled, then nscd will fail and there won't be any network
    # why? idk
    useNixStoreImage = true;
    writableStore = true;
  };
}
