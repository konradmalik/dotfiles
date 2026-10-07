# both rpi4s at their real addresses, so the hardcoded scrape targets and the
# exporters' firewall rules are exercised as they are in the house
{ testers }:
testers.runNixOSTest (
  { lib, ... }:
  let
    # added next to the address the test network assigns, on the same link
    pi =
      address: extraAddresses:
      { pkgs, ... }:
      {
        imports = [
          ../blocky.nix
          ./agents.nix
        ];

        networking.interfaces.eth1.ipv4.addresses = map (address: {
          inherit address;
          prefixLength = 24;
        }) ([ address ] ++ extraAddresses);

        services.blocky = {
          enable = true;
          # no network here, and "blocking" refuses to start without its upstreams
          settings.upstreams.init.strategy = lib.mkForce "fast";
        };

        environment.systemPackages = [ pkgs.curl ];
      };
  in
  {
    name = "monitoring";

    nodes = {
      pi1 = pi "192.168.88.2" [ ];
      pi2 = {
        imports = [
          # grafana binds to the tailscale address
          (pi "192.168.88.3" [ "100.78.182.5" ])
          ./prometheus.nix
          ./grafana.nix
        ];
      };
    };

    testScript =
      # python
      ''
        import json

        start_all()
        pi2.wait_for_unit("prometheus.service")
        pi2.wait_for_unit("grafana.service")

        with subtest("prometheus scrapes every exporter on both pis"):
            def all_up(last_try):
                targets = json.loads(pi2.succeed("curl -sf http://127.0.0.1:9090/api/v1/targets"))["data"]["activeTargets"]
                health = {t["scrapeUrl"]: t["health"] for t in targets}
                if last_try:
                    print(health)
                return len(health) == 6 and all(h == "up" for h in health.values())

            retry(all_up)

        with subtest("grafana serves on its bind address with the prometheus datasource"):
            pi2.wait_until_succeeds("curl -sf http://100.78.182.5:3000/api/health")
            pi2.succeed("curl -sf -u admin:admin http://100.78.182.5:3000/api/datasources/name/Prometheus")
      '';
  }
)
