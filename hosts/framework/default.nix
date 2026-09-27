{
  config,
  inputs,
  ...
}:
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
    OnFailure = "${config.konrad.services.ntfy.problemServiceName}@%i.service";
  };

  konrad.services.hd-idle.enable = true;
}
