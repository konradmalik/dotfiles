{ config, pkgs, ... }:
let
  stateDir = "/var/lib/private/beszel-hub";
  systems = (pkgs.formats.yaml { }).generate "beszel-config.yml" {
    systems = [
      {
        name = "rpi4-1";
        host = "127.0.0.1";
      }
      {
        name = "rpi4-2";
        host = "192.168.88.3";
      }
    ];
  };
in
{
  sops.secrets = {
    "beszel/hub-key".restartUnits = [ "beszel-hub.service" ];
    "beszel/hub-env".restartUnits = [ "beszel-hub.service" ];
  };

  services.beszel.hub = {
    enable = true;
    host = "0.0.0.0";
    environmentFile = config.sops.secrets."beszel/hub-env".path;
  };

  systemd.tmpfiles.rules = [ "d /mnt/beszel-hub :0700 :root :root -" ];
  fileSystems.${stateDir} = {
    device = "/mnt/beszel-hub";
    fsType = "none";
    options = [
      "bind"
      "nofail"
    ];
  };

  systemd.services.beszel-hub = {
    unitConfig.RequiresMountsFor = [ stateDir ];
    serviceConfig = {
      LoadCredential = [ "id_ed25519:${config.sops.secrets."beszel/hub-key".path}" ];
      ExecStartPre = [
        (pkgs.writeShellScript "beszel-hub-config" ''
          mkdir -p beszel_data
          ln -sfn ${systems} beszel_data/config.yml
          ln -sfn "$CREDENTIALS_DIRECTORY/id_ed25519" beszel_data/id_ed25519
        '')
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.beszel.hub.port ];
}
