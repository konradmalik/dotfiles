{ lib, ... }:
{
  imports = [ ./nixos.nix ];

  home-manager.users.konrad.imports = [ ../../home/profiles/server.nix ];

  konrad.services = {
    autoupgrade.enable = true;
    healthcheck.enable = lib.mkDefault true;
    syncthing = {
      enable = true;
      bidirectional = false;
    };
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    AllowHybridSleep = "no";
  };
}
