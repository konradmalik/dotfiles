{
  imports = [
    ./hardware-configuration.nix

    ../common/profiles/rpi4.nix

    ../common/modules/spotifyd.nix
  ];

  networking.hostName = "rpi4-1";

  services.blocky.enable = true;

  konrad.services = {
    dhcp =
      let
        ip = "192.168.100.2";
      in
      {
        enable = true;
        defaultGateway = "192.168.100.1";
        staticIP = ip;
        interface = "end0";
        dhcp-range = "192.168.100.126,192.168.100.254,255.255.255.0,24h";
        dhcp-dns = [
          ip
          "192.168.100.3"
        ];
      };
  };

  services.shairport-sync = {
    enable = true;
    arguments = "-a rpi4-1 -v -o alsa";
    openFirewall = true;
  };
}
