{
  imports = [ ../systems/nixos.nix ];

  konrad.network.wireless.enable = true;
  konrad.services.autoupgrade.enable = true;

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';
}
