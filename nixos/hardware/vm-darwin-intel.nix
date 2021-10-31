# This file is normally automatically generated. Since we build a VM
# and have full control over that hardware I can hardcode this into my
# repository.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { 
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { 
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  swapDevices = [ ];

  virtualisation.vmware.guest.enable = true;

  # internet access
  networking.interfaces.ens33.useDHCP = true;

  # We expect to run the VM on hidpi machines.
  hardware.video.hidpi.enable = false;

 }
