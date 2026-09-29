{ lib, ... }:
{
  options.sshKeys.personal.keys = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [ "ssh-ed25519 AAAA..." ];
    description = "public keys that are authorized to log in as this user";
  };
}
