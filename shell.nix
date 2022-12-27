let
  flakeLock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgsRev = flakeLock.nodes.nixpkgs.locked.rev;
  lockedNixpkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/${nixpkgsRev}.tar.gz") { };
in
{ pkgs ? lockedNixpkgs }:
with pkgs;
mkShell {
  name = "dotfiles-shell";
  nativeBuildInputs = [
    # nix
    nil
    nixpkgs-fmt
    # lua (neovim)
    sumneko-lua-language-server
    # yaml
    nodePackages.yaml-language-server
  ];
}
