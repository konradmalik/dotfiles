{ lib, inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4

    ./server.nix

    ../modules/blocky.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
  # disk with this label on first boot. Therefore, we need to keep it. It is the
  # only information from the installer image that we need to keep persistent
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    # spare the sd card a write on every read
    options = [ "noatime" ];
  };

  # journald defaults to up to 4G on / which is a lot for an sd card
  services.journald.settings.Journal.SystemMaxUse = "256M";

  # no swap on disk only because / is an sd card: swapping would wear it out and
  # be painfully slow. compressed swap in ram instead
  zramSwap.enable = true;

  # the pi's bootloader eeprom isn't on lvfs, so fwupd has nothing to update here;
  # it's updated with rpi-eeprom-update instead, see the readme
  services.fwupd.enable = false;

  boot.supportedFilesystems.zfs = lib.mkForce false;
  # workaround for https://github.com/NixOS/nixpkgs/issues/344963
  boot.initrd.systemd.tpm2.enable = false;
}
