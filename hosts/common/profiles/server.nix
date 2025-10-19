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

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';
}
