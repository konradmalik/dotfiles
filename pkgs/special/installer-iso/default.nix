{ pkgs, specialArgs }:
let
  nixosEvaluation = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    modules =
      [
        (
          { ... }: {
            config.nixpkgs.pkgs = pkgs;
          }
        )
        (import ./module.nix)
      ];
    system = "x86_64-linux";
    inherit specialArgs;
  };
in
nixosEvaluation.config.system.build.isoImage
