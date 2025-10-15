{ config, lib, ... }:
{
  networking.firewall = {
    allowedTCPPorts = lib.optional config.services.blocky.enable config.services.blocky.settings.ports.http;
    allowedUDPPorts = lib.optional config.services.blocky.enable config.services.blocky.settings.ports.dns;
  };

  services.blocky = {
    settings = {
      ports = {
        dns = 53;
        http = 4000;
      };
      upstreams = {
        init.strategy = "failOnError";
        groups.default = [
          "https://cloudflare-dns.com/dns-query"
          "https://dns.quad9.net/dns-query"
          "https://doh.mullvad.net/dns-query"
          "https://mozilla.cloudflare-dns.com/dns-query"
          "https://dns.google/dns-query"
        ];
      };
      bootstrapDns = [
        {
          upstream = "https://one.one.one.one/dns-query";
          ips = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        }
        {
          upstream = "https://dns.quad9.net/dns-query";
          ips = [
            "9.9.9.9"
            "149.112.112.112"
          ];
        }
      ];
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
