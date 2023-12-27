{
  imports = [
    ./hardware-configuration.nix
    ./../common/presets/nixos.nix
  ];

  networking.hostName = "rpi4-2";

  konrad.networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
  };

  konrad.services.autoupgrade = {
    enable = true;
  };

  networking.firewall.enable = false;
}
