{ config, pkgs, lib, inputs, outputs, ... }:
{
  nixpkgs = {
    overlays = [
      outputs.overlays.modifications
      outputs.overlays.additions

      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = final.system;
          config = final.config;
        };

        master = import inputs.nixpkgs-master {
          system = final.system;
          config = final.config;
        };

      })
    ];
    config = {
      allowUnfree = true;
    };
  };
  nix = {
    package = pkgs.nix;
    # should be >= max-jobs
    nrBuildUsers = 16;

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      keep-derivations = true;
      keep-outputs = true;
      trusted-users = [ "root" ]
        ++ lib.optional pkgs.stdenv.isLinux "@wheel"
        ++ lib.optional pkgs.stdenv.isDarwin "@admins";
      substituters = [
        "https://konradmalik.cachix.org"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "konradmalik.cachix.org-1:9REXmCYRwPNL0kAB0IMeTxnMB1Gl9VY5I8w7UVBTtSI="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    # Map registries to channels
    # Very useful when using legacy commands
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
  };
}
