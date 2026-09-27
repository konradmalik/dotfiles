{ lib, ... }:
{
  services.openssh = {
    enable = true;
    # disable rsa keys
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    # Automatically remove stale sockets
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
    # Allow forwarding ports to everywhere
    settings = {
      GatewayPorts = "clientspecified";
      PasswordAuthentication = false;
      PermitRootLogin = lib.mkDefault "no";
    };
  };

  # Allow to authenticate users using only ssh keys
  # from "/etc/ssh/authorized_keys.d/%u"
  security.pam.sshAgentAuth.enable = true;
  # Passwordless sudo when SSH'ing with keys
  # from "/etc/ssh/authorized_keys.d/%u"
  security.pam.services.sudo.sshAgentAuth = true;
}
