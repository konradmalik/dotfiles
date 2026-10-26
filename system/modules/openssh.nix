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

  # Passwordless sudo when SSH'ing with a forwarded agent holding a key
  # from "/etc/ssh/authorized_keys.d/$ruser" (the module's default).
  # pam_rssh allows to parse sk-* (secure enclave) keys
  security.pam.rssh.enable = true;
  security.pam.services.sudo.rssh = true;
}
