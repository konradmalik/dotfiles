# boots blocky.nix as-is, with no network: the real denylist downloads fail, which
# also proves the "fast" loading keeps DNS up when list sources are unreachable
{ testers }:
testers.runNixOSTest (
  { nodes, lib, ... }:
  {
    name = "blocky";

    nodes = {
      dns = {
        imports = [ ./blocky.nix ];

        services.blocky = {
          enable = true;
          settings = {
            # the DoH upstreams are unreachable here, and "blocking" refuses to start without them
            upstreams.init.strategy = lib.mkForce "fast";
            # answered locally, so no upstream is needed. ads.test is mapped too, so a
            # 0.0.0.0 answer can only come from blocking, not from a failed lookup
            customDNS.mapping = {
              "ok.test" = "10.0.0.1";
              "ads.test" = "10.0.0.2";
            };
            # concatenated onto the real ads lists
            blocking.denylists.ads = [
              ''
                ads.test
              ''
            ];
          };
        };
      };

      client =
        { pkgs, ... }:
        {
          environment.systemPackages = [ pkgs.dnsutils ];
        };
    };

    testScript =
      let
        dnsIP = nodes.dns.networking.primaryIPAddress;
      in
      # python
      ''
        start_all()
        dns.wait_for_unit("blocky.service")
        dns.wait_for_open_port(53)

        # over the network, so the firewall rules are exercised too
        client.wait_until_succeeds("dig +short @${dnsIP} ok.test | grep -x 10.0.0.1")
        client.succeed("dig +short @${dnsIP} ads.test | grep -x 0.0.0.0")
      '';
  }
)
