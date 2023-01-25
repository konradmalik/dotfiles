{ lib, ... }:
{
  options.sshKeys = {
    personal = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };
}
