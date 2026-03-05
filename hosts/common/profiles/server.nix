{ lib, ... }:
{
  imports = [ ../systems/nixos.nix ];

  konrad.network.wireless.enable = true;

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
