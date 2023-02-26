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

        konradmalik = import inputs.nixpkgs-konradmalik {
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
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      keep-derivations = true;
      keep-outputs = true;
      trusted-users = [ "root" ]
        ++ lib.optional pkgs.stdenvNoCC.isLinux "@wheel"
        ++ lib.optional pkgs.stdenvNoCC.isDarwin "@admins";
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
      min-free = lib.mkDefault (10 * 1000 * 1000 * 1000); # 10gb
      cores = lib.mkDefault 0;
      max-jobs = lib.mkDefault "auto";
    };

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    # this becomes registry.nixpkgs.flake = inputs.nixpkgs etc. for all inputs
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
  }
  # below checks if this is home-manager-applied or nixos/nix-darwin-applied
  # (those options do not exist in home-manager)
  // lib.optionalAttrs (builtins.hasAttr "nixPath" config.nix) {
    # should be >= max-jobs
    nrBuildUsers = 16;
    # Map registries to channels
    # Very useful when using legacy commands
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };
}
