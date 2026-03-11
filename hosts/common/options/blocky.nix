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
            # https://github.com/hagezi/dns-blocklists
            "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.plus.txt"
            # https://github.com/MajkiIT/polish-ads-filter
            "https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-pihole-filters/hostfile.txt"
          ];
          security = [
            # https://github.com/hagezi/dns-blocklists#threat-intelligence-feeds
            "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/tif.txt"
            # https://cert.pl
            "https://hole.cert.pl/domains/domains.txt"
            # https://github.com/FiltersHeroes/KADhosts
            "https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADomains.txt"
          ];
          fakenews = [
            # https://github.com/StevenBlack/hosts
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"
          ];
          gambling = [
            # https://github.com/MajkiIT/polish-ads-filter
            "https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-pihole-filters/gambling-hosts.txt"
          ];
        };
        clientGroupsBlock = {
          default = [
            "ads"
            "security"
            "fakenews"
            "gambling"
          ];
        };
        loading = {
          strategy = "failOnError";
        };
      };
    };
  };
}
