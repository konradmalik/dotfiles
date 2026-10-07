# a fake healthchecks.io on localhost, with the URL file rewritten from the test
# script to point at a ping that exists and at one that does not
{ testers }:
testers.runNixOSTest {
  name = "healthcheck";

  nodes.machine =
    { pkgs, ... }:
    {
      imports = [ ./healthcheck.nix ];

      konrad.services.healthcheck = {
        enable = true;
        urlFile = "/run/healthcheck-url";
      };

      systemd.services.fake-hc = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig.ExecStart = "${pkgs.python3}/bin/python3 -m http.server 8000 --bind 127.0.0.1 --directory /srv";
      };

      systemd.tmpfiles.rules = [
        "d /srv/ping 0755 root root -"
        "f /srv/ping/test-uuid 0644 root root - OK"
      ];
    };

  testScript =
    # python
    ''
      machine.wait_for_unit("healthcheck.timer")
      machine.wait_for_unit("fake-hc.service")
      machine.wait_for_open_port(8000)

      with subtest("pings the URL from the file"):
          machine.succeed("echo http://127.0.0.1:8000/ping/test-uuid > /run/healthcheck-url")
          machine.succeed("systemctl start healthcheck.service")
          machine.succeed("journalctl -u fake-hc.service | grep -F 'GET /ping/test-uuid'")

      with subtest("fails when the endpoint rejects the ping"):
          machine.succeed("echo http://127.0.0.1:8000/ping/missing > /run/healthcheck-url")
          machine.fail("systemctl start healthcheck.service")
    '';
}
