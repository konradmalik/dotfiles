{ config, ... }:
let
  publicDns = [
    #Google
    "8.8.8.8"
    "8.8.4.4"
    #Control D
    "76.76.2.0"
    "76.76.10.0"
    #Quad9
    "9.9.9.9"
    "149.112.112.112"
    #OpenDNS Home
    "208.67.222.222"
    "208.67.220.220"
    #Cloudflare
    "1.1.1.1"
    "1.0.0.1"
    #AdGuard DNS
    "94.140.14.14"
    "94.140.15.15"
    #CleanBrowsing
    "185.228.168.9"
    "185.228.169.9"
    #Alternate DNS
    "76.76.19.19"
    "76.223.122.150"
  ];
in
{
  services.blocky = {
    enable = true;
    settings = {
      ports = {
        dns = 53;
        tls = 853;
        http = 4000;
      };
      upstreams = {
        init.strategy = "failOnError";
        groups = {
          default =
            # TODO enable once unbound works
            # if config.services.unbound.enable then
            #   [ "127.0.0.1:${toString config.services.unbound.settings.server.port}" ]
            # else
            publicDns;
        };
      };
      blocking = {
        denylists = {
          ads = [
            "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "http://sysctl.org/cameleon/hosts"
            "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
          ];
          fakenews = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts"
          ];
        };
        clientGroupsBlock = {
          default = [
            "ads"
            "fakenews"
          ];
        };
        loading = {
          strategy = "failOnError";
        };
      };
    };
  };
}
