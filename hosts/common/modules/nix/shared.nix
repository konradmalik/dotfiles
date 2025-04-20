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
      # FIXME after https://github.com/NixOS/nixpkgs/issues/399907
      (final: prev: {
        qt6Packages = prev.qt6Packages.overrideScope (
          _: kprev: {
            qt6gtk2 = kprev.qt6gtk2.overrideAttrs (_: {
              version = "0.5-unstable-2025-03-04";
              src = final.fetchFromGitLab {
                domain = "opencode.net";
                owner = "trialuser";
                repo = "qt6gtk2";
                rev = "d7c14bec2c7a3d2a37cde60ec059fc0ed4efee67";
                hash = "sha256-6xD0lBiGWC3PXFyM2JW16/sDwicw4kWSCnjnNwUT4PI=";
              };
            });
          }
        );
      })
    ];
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };
  };
  nix = {
    package = pkgs.nixVersions.latest;
    registry = {
      # Setting only non standards here. Eg. "nixpkgs" is set by default.
      nixpkgs-stable.flake = inputs.nixpkgs-stable;
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      keep-derivations = true;
      keep-outputs = true;
      trusted-users =
        [ "root" ]
        ++ lib.optional pkgs.stdenvNoCC.isLinux "@wheel"
        ++ lib.optional pkgs.stdenvNoCC.isDarwin "@admin";
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
