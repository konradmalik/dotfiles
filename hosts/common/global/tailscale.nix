{ config, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;
    authKeyFile = config.sops.secrets.tailscale-auth-key.path;
  };

  # setup a key secret
  sops.secrets.tailscale-auth-key = { };
}
