let
  flakeLock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgsRev = flakeLock.nodes.nixpkgs.locked.rev;
  lockedNixpkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/${nixpkgsRev}.tar.gz") { };
  sopsNixRev = flakeLock.nodes.sops-nix.locked.rev;
  lockedSopsNix = builtins.fetchTarball {
    url = "https://github.com/Mic92/sops-nix/archive/${sopsNixRev}.tar.gz";
    sha256 = flakeLock.nodes.sops-nix.locked.narHash;
  };
in
{ pkgs ? lockedNixpkgs, sops-nix ? lockedSopsNix }:
with pkgs;
mkShell {
  name = "dotfiles-shell";

  # imports all files ending in .asc/.gpg
  sopsPGPKeyDirs = [
    # "${toString ./.}/keys/hosts"
    "${toString ./nix/secrets}/keys/users"
  ];

  # stores in .git/gnupg
  sopsCreateGPGHome = true;

  nativeBuildInputs = [
    # nix
    nil
    nixpkgs-fmt
    # https://discourse.nixos.org/t/how-to-run-nixos-rebuild-target-host-from-darwin/9488/3
    nixos-rebuild
    # lua (neovim)
    sumneko-lua-language-server
    # yaml
    nodePackages.yaml-language-server
    # sops-nix
    (pkgs.callPackage sops-nix { }).sops-import-keys-hook
    age
    sops
    ssh-to-age
  ];
}
