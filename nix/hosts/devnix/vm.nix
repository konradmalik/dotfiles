{ config, pkgs, lib, modulesPath, inputs, ... }:
let
  cores = 4;
  diskSize = 40 * 1024;
  memorySize = 8 * 1024;

  arch = "x86_64";
  system = "darwin";
  user = "konrad";

  homePrefix = if system == "darwin" then "/Users" else "/home";
in
{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "${arch}-linux";

  # otherwise no internet in the vm on darwin
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  users.extraUsers.root.password = "";
  services.getty.autologinUser = "root";

  virtualisation = {
    inherit cores diskSize memorySize;

    # host.pkgs = hostPkgs;
    diskImage = "./VMs/${config.system.name}.qcow2";

    forwardPorts = [
      { from = "host"; guest.port = 22; host.port = 2222; }
    ];

    graphics = false;

    host.pkgs = inputs.nixpkgs.legacyPackages."${arch}-${system}";

    sharedDirectories = {
      hostHome = {
        source = "${homePrefix}/${user}/Code";
        target = "/home/${user}/Code";
      };
    };
  };
}
