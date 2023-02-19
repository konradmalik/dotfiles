{ config, pkgs, lib, modulesPath, inputs, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"

    ./../../common/global/docker.nix
  ];

  # nixpkgs.hostPlatform = "x86_64-linux";

  documentation.enable = false;

  networking = {
    hostName = "darwin-docker";
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
  };

  users.users.docker = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };
  services.getty.autologinUser = "docker";
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = lib.mkDefault "22.11";

  virtualisation = {
    vmVariant = {
      virtualisation = {
        host.pkgs = inputs.nixpkgs.legacyPackages.x86_64-darwin;
        graphics = false;

        diskSize = 20 * 1024;

        memorySize = 3 * 1024;

        forwardPorts = [
          { from = "host"; guest.port = 2375; host.port = 2375; }
        ];
      };

      networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
    };
  };
}
