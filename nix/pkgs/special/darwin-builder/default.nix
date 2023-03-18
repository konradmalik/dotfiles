{ hostPkgs, guestPkgs }:
let
  nixosEvaluation = guestPkgs.nixos (import ./module.nix { inherit hostPkgs guestPkgs; });
in
nixosEvaluation.config.system.build.macos-builder-installer
