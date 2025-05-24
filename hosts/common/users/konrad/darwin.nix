{ config, pkgs, ... }:
let
  username = "konrad";
in
{
  home-manager.users.${username} =
    import ./../../../../home/${username}/${config.networking.hostName}.nix;

  system.primaryUser = username;

  users.users.${username} = {
    name = username;
    home = "/Users/${config.users.users.konrad.name}";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = config.home-manager.users.konrad.sshKeys.personal.keys;
  };
}
