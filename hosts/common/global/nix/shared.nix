{ config, pkgs, lib, inputs, customArgs, ... }:
let
  # Add each flake input as a registry
  # To make nix3 commands consistent with the flake
  # this becomes registry.nixpkgs.flake = inputs.nixpkgs etc. for all inputs
  registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
  # Map registries to channels
  # very useful when using legacy commands (they use NIX_PATH and this is what we are building here)
  # also make sure that no imperative channels are in use: nix-channel --list should be empty
  nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
in
{
  nixpkgs = {
    overlays = [
      customArgs.overlays.modifications
      customArgs.overlays.additions

      (final: prev: {
        stable = import inputs.nixpkgs-stable {
          system = final.system;
          config = final.config;
        };
      })
    ];
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };
  };
  nix = {
    inherit registry;
    package = pkgs.nixUnstable;
    settings = {
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      keep-derivations = true;
      keep-outputs = true;
      trusted-users = [ "root" ]
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
  }
  # those options do not exist in plain home-manager
  # but it will work for nixos config and for nix-darwin config
  # this check is needed because of generic linux entry in homeConfigurations
  // lib.optionalAttrs (builtins.hasAttr "nixPath" config.nix) {
    inherit nixPath;
    # should be >= max-jobs
    nrBuildUsers = 16;
  };
}
