{ config, pkgs, ... }:
{
  services.tailscale.enable = true;
  networking.firewall = {
    checkReversePath = "loose";
    # https://tailscale.com/kb/1082/firewall-ports/
    allowedUDPPorts = [
      3478 # stun
      config.services.tailscale.port # direct wireguard
    ];
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
  };

  # setup a key secret
  sops.secrets.tailscale-auth-key = { };

  # create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoauth = {
    description = "Automatic authentication to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      echo "waiting 5 sec..."
      sleep 5

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then
        # if so, then do nothing
        echo "already authenticated"
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up -authkey $(cat ${config.sops.secrets.tailscale-auth-key.path})
    '';
  };
}