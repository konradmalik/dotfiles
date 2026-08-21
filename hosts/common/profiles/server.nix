{ config, lib, ... }:
{
  imports = [ ../systems/nixos.nix ];

  sops.secrets."wifi/home" = { };
  sops.secrets."wifi/hotspot" = { };
  konrad.network.wireless = {
    enable = true;
    networks = {
      "pozdrawiamhipstera".passphraseFile = config.sops.secrets."wifi/home".path;
      "Konrad’s iPhone".passphraseFile = config.sops.secrets."wifi/hotspot".path;
    };
  };

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
