{
  imports = [
    ./hardware-configuration.nix
    ./../common/modules/blocky.nix
    ./../common/nixos.nix
  ];

  networking.hostName = "rpi4-2";

  konrad.services.autoupgrade = {
    enable = true;
  };

  networking.firewall.enable = false;
}
