{ lib, inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
  # disk with this label on first boot. Therefore, we need to keep it. It is the
  # only information from the installer image that we need to keep persistent
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  boot.supportedFilesystems.zfs = lib.mkForce false;
  # workaround for https://github.com/NixOS/nixpkgs/issues/344963
  boot.initrd.systemd.tpm2.enable = false;
}
