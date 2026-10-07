# the restic option through home-manager, with a local repository. Old
# snapshots are seeded with plain restic, since baker's backup takes no --time.
{ pkgs, inputs }:
let
  # baker notifies through custom.scripts.ntfy-send. Test nodes get a read-only
  # pkgs, so the overlay is applied to the one the test is built from instead.
  pkgs' = pkgs.extend (final: prev: { custom = import ../../../pkgs final; });
in
pkgs'.testers.runNixOSTest {
  name = "restic";

  nodes.machine =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      users.users.konrad = {
        isNormalUser = true;
        uid = 1000;
      };

      environment = {
        systemPackages = [ pkgs.restic ];
        etc = {
          "restic-password".text = "test";
          # nothing listens at ntfy.sh here, so failures only get as far as trying
          "ntfy-token".text = "token";
          "ntfy-topic".text = "topic";
        };
      };

      systemd.tmpfiles.rules = [ "d /var/backup 0755 konrad users -" ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.konrad = {
          imports = [ ./. ];

          home.stateVersion = "26.11";

          konrad.programs.restic = {
            enable = true;
            passwordFile = "/etc/restic-password";
            ntfy = {
              tokenFile = "/etc/ntfy-token";
              topicFile = "/etc/ntfy-topic";
            };
            repositories.local = {
              repository = "/var/backup/restic";
              includes = [ "/home/konrad/data" ];
            };
          };
        };
      };
    };

  testScript =
    # python
    ''
      import json
      import shlex

      def konrad(cmd):
          return machine.succeed(f"su - konrad -c {shlex.quote(cmd)}")

      def exit_code(cmd):
          return int(konrad(f"{cmd} >/dev/null 2>&1; echo $?").strip())

      restic = "RESTIC_REPOSITORY=/var/backup/restic RESTIC_PASSWORD_FILE=/etc/restic-password restic"

      machine.wait_for_unit("home-manager-konrad.service")

      konrad(
          "mkdir -p data/sub data/node_modules/pkg data/skip"
          " && echo keep > data/keep.txt"
          " && echo nested > data/sub/file"
          " && echo dep > data/node_modules/pkg/index.js"
          " && echo secret > data/skip/file && touch data/skip/.nobackup"
      )

      with subtest("scheduled jobs skip a local repository that is not there"):
          assert "is not available, skipping" in konrad("baker-local run backup")

      with subtest("the watchdog fails while only old snapshots exist"):
          konrad("baker-local init")
          konrad(f"for d in $(seq -w 1 20); do {restic} backup -q /home/konrad/data --time \"2020-01-$d 12:00:00\"; done")
          # another host's fresh snapshot must not count for this one
          konrad(f"{restic} backup -q /home/konrad/data --host other")
          assert exit_code("baker-local run watchdog") == 90

      with subtest("backup and restore round trip, minus the excludes"):
          konrad("baker-local backup")
          konrad("baker-local restore latest --host machine --target /tmp/restore")
          konrad("diff /tmp/restore/home/konrad/data/keep.txt data/keep.txt")
          konrad("diff /tmp/restore/home/konrad/data/sub/file data/sub/file")
          konrad("test ! -e /tmp/restore/home/konrad/data/node_modules")
          konrad("test ! -e /tmp/restore/home/konrad/data/skip")

      with subtest("the watchdog passes after a fresh backup"):
          assert exit_code("baker-local watchdog") == 0

      with subtest("forget applies the default retention per host"):
          konrad("baker-local forget")
          snapshots = json.loads(konrad(f"{restic} snapshots --json"))
          kept = sorted(s["time"][:10] for s in snapshots if s["hostname"] == "machine")
          # hourly 12 keeps the 12 newest, which already cover every other rule
          old = [f"2020-01-{d:02}" for d in range(10, 21)]
          assert kept[:-1] == old and not kept[-1].startswith("2020"), kept
          assert sum(s["hostname"] == "other" for s in snapshots) == 1

      with subtest("every job has its timer"):
          for job in ["backup", "check", "forget", "watchdog"]:
              konrad(f"test -L .config/systemd/user/timers.target.wants/baker-local-{job}.timer")
    '';
}
