{ config, lib, ... }:
{
  networking.firewall = {
    allowedTCPPorts = lib.optionals config.services.blocky.enable [
      config.services.blocky.settings.ports.dns
      config.services.blocky.settings.ports.http
    ];
    allowedUDPPorts = lib.optional config.services.blocky.enable config.services.blocky.settings.ports.dns;
  };

  networking.nameservers = lib.mkIf config.services.blocky.enable [
    "1.1.1.1"
    "1.0.0.1"
  ];

  # nixpkgs' module only "wants" network-online.target without ordering after it,
  # so blocky's upstream resolver test races the network coming up on boot
  systemd.services.blocky = lib.mkIf config.services.blocky.enable {
    after = [ "network-online.target" ];
  };

  services.blocky = {
    settings = {
      ports = {
        dns = 53;
        http = 4000;
      };
      upstreams = {
        init.strategy = "blocking";
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
            # KADomains.txt is the FortiGate variant (carries bare IPs blocky can't parse),
            # KADhosts.txt is the DNS-blocker one. Same domains.
            "https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADhosts.txt"
          ];
          fakenews = [
            # https://github.com/StevenBlack/hosts
            # keep this over hagezi's fake.txt: that one is fully contained in pro.plus+tif
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"
          ];
          gambling = [
            # https://github.com/hagezi/dns-blocklists
            "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/gambling.medium.txt"
            # https://github.com/MajkiIT/polish-ads-filter
            # still adds ~1.5k PL domains that hagezi's medium tier misses
            "https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-pihole-filters/gambling-hosts.txt"
          ];
        };
        # false positives go here. allowlists win over denylists across *all* of a
        # client's groups, so this one also excepts hits from security/gambling/etc.
        allowlists.ads = [
          ''
            # example.com
          ''
        ];
        clientGroupsBlock = {
          default = [
            "ads"
            "security"
            "fakenews"
            "gambling"
          ];
        };
        loading = {
          # serve DNS immediately and seed lists from cachePath, instead of refusing
          # to start when a single source is briefly unreachable
          strategy = "fast";
          downloads = {
            cachePath = "/var/lib/blocky/lists";
            # tif.txt is ~42MB; the 5s default is Go's whole-request budget
            # (body read included), so it truncates the list mid-download
            timeout = "5m";
            readTimeout = "5m";
          };
        };
      };
    };
  };
}
