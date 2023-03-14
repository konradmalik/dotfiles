{
  description = "Development environment for this project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        mkOverlay = input: name: (final: prev: {
          "${name}" = import input {
            system = final.system;
            config = final.config;
          };
        });
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (mkOverlay nixpkgs-unstable "unstable")
          ];
        };
      in
      rec {
        devShells = {
          default = pkgs.mkShell
            {
              name = "Shell for this project";

              packages = with pkgs; [
                # formatters/linters
                formatter
                # language-servers
                nil
              ];
            };
        };
        formatter = pkgs.nixpkgs-fmt;
      });
}
