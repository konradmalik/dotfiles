{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-desktop-amd-ai-max-300-series

    ./hardware.nix
    ./disko.nix

    ../../system/modules/llama
    ../../system/profiles/desktop.nix
  ];

  home-manager.users.konrad.imports = [ ./home.nix ];

  networking.hostName = "framework";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-partlabel/framework-borg";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  konrad.services.hd-idle.enable = true;
}
