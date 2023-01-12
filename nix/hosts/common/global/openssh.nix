{ config, pkgs, lib, username, ... }:
{
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    ports = [ 22 ];
    hostKeys = [{
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }];
  };

  networking.firewall = {
    allowedTCPPorts = config.services.openssh.ports;
  };
}
