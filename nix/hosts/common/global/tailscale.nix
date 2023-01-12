{ ... }:
{
  # Enable tailscale. We manually authenticate when we want with
  # "sudo tailscale up". If you don't use tailscale, you should comment
  # out or delete all of this.
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
