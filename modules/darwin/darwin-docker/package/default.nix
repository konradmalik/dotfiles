{ guestPkgs }:
let
  nixosEvaluation = guestPkgs.nixos (import ./module.nix { });
in
nixosEvaluation.config.system.build.vm
