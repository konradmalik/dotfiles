{ config, ... }:
{
  imports = [ ../systems/nixos.nix ];

  konrad.network.wireless.enable = true;
  konrad.services.autoupgrade.enable = true;
  konrad.services.healthcheck = {
    enable = true;
    urlFile = config.sops.secrets.healthcheck.path;
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';
}
