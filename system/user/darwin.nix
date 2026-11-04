{ config, pkgs, ... }:
let
  username = "konrad";
in
{
  system.primaryUser = username;

  # listed in /etc/shells, which macOS expects of a login shell
  environment.shells = [ pkgs.zsh ];

  users = {
    # nix-darwin only applies properties like shell to known users; for an existing
    # account that is just the shell (uids <= 501 are never deleted)
    knownUsers = [ username ];
    users.${username} = {
      name = username;
      uid = 501;
      home = "/Users/${config.users.users.konrad.name}";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = config.home-manager.users.konrad.sshKeys.personal.keys;
    };
  };
}
