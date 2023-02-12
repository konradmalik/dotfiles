{ config, pkgs, lib, modulesPath, inputs, ... }:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"

    ./../../common/global/docker.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  documentation.enable = false;

  networking = {
    hostName = "macos-docker";
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
  };

  users.users.docker = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };
  services.getty.autologinUser = "docker";
  security.sudo.wheelNeedsPassword = false;

  environment.etc = {
    "ssh/ssh_host_ed25519_key" = {
      mode = "0600";

      source = ./keys/ssh_host_ed25519_key;
    };

    "ssh/ssh_host_ed25519_key.pub" = {
      mode = "0644";

      source = ./keys/ssh_host_ed25519_key.pub;
    };
  };

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
