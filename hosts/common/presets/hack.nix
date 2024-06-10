{ lib, ... }:
{
  options = {
    system.nixos.codeName = lib.mkOption { readOnly = false; };
  };

  config = {
    # https://github.com/NixOS/nixpkgs/issues/315574
    system.nixos.codeName = "Vicuna";
  };
}
