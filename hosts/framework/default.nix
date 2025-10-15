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

    ../common/profiles/desktop.nix
  ];

  networking.hostName = "framework";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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

  konrad.services.hd-idle.enable = true;
}
