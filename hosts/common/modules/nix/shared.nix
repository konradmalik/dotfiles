{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  isHomeManager = builtins.hasAttr "hm" lib;
in
{
  imports = lib.optionals (!isHomeManager) [ ./not-hm.nix ];

  nixpkgs = {
    overlays = [
      (
        final: prev:
        (import ../../../../pkgs/installable { pkgs = final; })
        // {
          stable = import inputs.nixpkgs-stable {
            system = final.system;
            config = final.config;
          };
        }
      )
    ];
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };
  };
  nix = {
    package = pkgs.nixVersions.latest;
    # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nixpkgs-stable.flake = inputs.nixpkgs-stable;
    };
    settings = {
      # NIX_PATH is still used by many useful tools, so we set it to the same value as the one used by this flake.
      # https://github.com/NixOS/nix/issues/9574
      nix-path = lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      keep-derivations = true;
      keep-outputs = true;
      trusted-users =
        [ "root" ]
        ++ lib.optional pkgs.stdenvNoCC.isLinux "@wheel" ++ lib.optional pkgs.stdenvNoCC.isDarwin "@admin";
      extra-substituters = [
        "https://konradmalik.cachix.org"
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "konradmalik.cachix.org-1:9REXmCYRwPNL0kAB0IMeTxnMB1Gl9VY5I8w7UVBTtSI="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
      ];
      min-free = lib.mkDefault (10 * 1000 * 1000 * 1000); # 10gb
      cores = lib.mkDefault 0;
      max-jobs = lib.mkDefault "auto";
    };
  };
}
