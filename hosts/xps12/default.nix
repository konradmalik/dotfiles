{
  imports = [
    ./hardware-configuration.nix
    ./../common/nixos.nix
  ];

  networking.hostName = "xps12";

  konrad.networking.wireless = {
    enable = true;
    interfaces = [ "wlp2s0" ];
  };

  konrad.services.autoupgrade = {
    enable = true;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services = {
    logind.lidSwitch = "ignore";
    rtcwake = {
      enable = true;
      # both UTC
      on = "tomorrow 07:00";
      off = "*-*-* 22:00:00";
      mode = "off";
    };
    offdisp = {
      enable = true;
      timeAfterBoot = "10min";
    };
  };
}
