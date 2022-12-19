# this is a dummy flake that I target for private files by default
# in order to use the real one, use --override-input, ex:
# --override-input dotfiles-private git+file:///home/konrad/Code/dotfiles-private
# or --override-input dotfiles-private github:konradmalik/dotfile-private
{
  description = "My dummy private dotfiles nix flake";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/release-22.11;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

      in
      {
        packages = {
          default = pkgs.stdenv.mkDerivation {
            name = "dummy-private-files";
            src = ./.;
            installPhase = ''
              mkdir -p $out/ssh
              touch $out/ssh/empty
            '';
          };
        };
      }
    );
}
