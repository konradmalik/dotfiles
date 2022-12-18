let
  flakeLock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgsRev = flakeLock.nodes.nixpkgs.locked.rev;
  lockedNixpkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/${flakeLock.nodes.nixpkgs.locked.rev}.tar.gz") { };
in
{ pkgs ? lockedNixpkgs }:
with pkgs;
mkShell {
  nativeBuildInputs = [
    # nix
    rnix-lsp
    nixpkgs-fmt
    # lua (neovim)
    sumneko-lua-language-server
    # yaml
    nodePackages.yaml-language-server
  ];
}
