{ hostPkgs, guestPkgs, specialArgs }:
let
  evalConfig = import "${toString guestPkgs.path}/nixos/lib/eval-config.nix";
  configuration = import ./module.nix { inherit hostPkgs guestPkgs; };
  eval = evalConfig {
    inherit (guestPkgs) system;
    inherit specialArgs;
    modules = [ configuration ];
  };
in
eval.config.system.build.vm
