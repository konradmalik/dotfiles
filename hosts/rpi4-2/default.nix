{
  imports = [
    ./hardware-configuration.nix
    ./../common/modules/blocky.nix
    ./../common/nixos.nix
  ];

  networking.hostName = "rpi4-2";

  networking.firewall.enable = false;

  services.blocky.enable = true;

  konrad.services = {
    autoupgrade = {
      enable = true;
    };
    syncthing = {
      enable = true;
      user = "konrad";
      bidirectional = false;
    };
  };
}
