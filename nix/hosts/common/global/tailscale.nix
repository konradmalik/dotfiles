{ ... }:
{
  services.tailscale.enable = true;
  networking.firewall = {
    checkReversePath = "loose";
    # https://tailscale.com/kb/1082/firewall-ports/
    allowedUDPPorts = [
      3478 # stun
      41641 # direct wireguard
    ];
  };
}
