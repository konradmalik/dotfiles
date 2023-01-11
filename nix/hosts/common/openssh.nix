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

  # If you are using NixOps then don't use this option since it will replace the key required for deployment via ssh.
  users.users.${username}.openssh.authorizedKeys.keys =
    let
      authorizedKeysFile = builtins.readFile "${pkgs.dotfiles}/ssh/authorized_keys";
      authorizedKeysFileLines = lib.splitString "\n" authorizedKeysFile;
      onlyKeys = lib.filter (line: line != "" && !(lib.hasPrefix "#" line)) authorizedKeysFileLines;
    in
    onlyKeys;
}
