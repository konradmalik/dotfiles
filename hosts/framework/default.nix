{
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series

    ./hardware-configuration.nix
    ./disko.nix

    ./../common/modules/hyprland.nix
    ./../common/nixos.nix
  ];

  networking.hostName = "framework";

  konrad.audio.enable = true;
  konrad.hardware.bluetooth.enable = true;
  konrad.network.wireless.enable = true;
  konrad.services = {
    autoupgrade = {
      enable = true;
      allowReboot = false;
      operation = "boot";
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.logind.settings.Login = {
    SleepOperation = "suspend";
    IdleAction = "suspend";
    IdleActionSec = "30min";
  };

  fileSystems = {
    "/mnt/borg" = {
      device = "/dev/disk/by-partlabel/framework-borg";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  };

  sops.secrets.framework-borg = { };
  konrad.services.borg = {
    enable = true;
    name = "home";
    repoPath = "/mnt/borg/home";
    passwordFile = config.sops.secrets.framework-borg.path;
    paths = [ "/home/konrad" ];
  };
  konrad.services.ntfy.enable = true;

  systemd.services.${config.konrad.services.borg.systemdName}.unitConfig = {
    RequiresMountsFor = "/mnt/borg";
    OnSuccess = "${config.konrad.services.ntfy.infoServiceName}@%i.service";
    OnFailure = "${config.konrad.services.ntfy.problemServiceName}@%i.service";
  };
}
