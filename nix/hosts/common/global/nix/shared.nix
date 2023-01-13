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
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
      keep-derivations = true;
      keep-outputs = true;
    };

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Map registries to channels
    # Very useful when using legacy commands
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };
}
