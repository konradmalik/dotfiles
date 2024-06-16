{
  imports = [
    ./hardware-configuration.nix
    ./../common/nixos.nix
  ];

  networking.hostName = "vaio";

  konrad.networking.wireless = {
    enable = true;
    interfaces = [ "wlp2s0" ];
  };

  konrad.services.autoupgrade = {
    enable = true;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # avoid overheat
  nix.settings = {
    cores = 2;
    max-jobs = 4;
  };

  services.logind.lidSwitch = "ignore";
}
