{ pkgs, inputs, outputs, ... }:
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
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
      keep-derivations = true;
      keep-outputs = true;
    };
  };
}
