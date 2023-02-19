{ pkgs, inputs, ... }:
let
  nixpkgs = inputs.nixpkgs-unstable;
  toGuest = builtins.replaceStrings [ "darwin" ] [ "linux" ];

  darwin-builder = import "${nixpkgs}/nixos/default.nix" {
    configuration = {
      imports = [
        "${nixpkgs}/nixos/modules/profiles/macos-builder.nix"
      ];

      virtualisation = {
        host = { inherit pkgs; };
        diskImage = "./darwinBuilder.qcow2";
      };
    };

    system = toGuest pkgs.stdenvNoCC.hostPlatform.system;
  };
in
darwin-builder.config.system.build.macos-builder-installer
