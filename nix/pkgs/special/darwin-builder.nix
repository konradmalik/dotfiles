{ pkgs, inputs, ... }:
let
  nixpkgs = inputs.nixpkgs-unstable;
  toGuest = builtins.replaceStrings [ "darwin" ] [ "linux" ];

  nixos = import "${nixpkgs}/nixos/default.nix" {
    configuration = {
      imports = [
        "${nixpkgs}/nixos/modules/profiles/macos-builder.nix"
      ];

      virtualisation = {
        host = { inherit pkgs; };
        diskImage = "./VMs/darwin-builder.qcow2";
      };

      system.stateVersion = "22.11";
    };

    system = toGuest pkgs.stdenvNoCC.hostPlatform.system;
  };
in
nixos.config.system.build.macos-builder-installer
