let
  flakeLock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgsLock = flakeLock.nodes.nixpkgs.locked;
  lockedNixpkgs = import
    (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgsLock.rev}.tar.gz";
      sha256 = nixpkgsLock.narHash;
    })
    { };
in
{ pkgs ? lockedNixpkgs }:
with pkgs;
mkShell {
  name = "dotfiles-shell";

  # Enable experimental features without having to specify the argument
  NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";

  packages = [
    # linters,formatters
    nixpkgs-fmt
    nodePackages.yaml-language-server
    sumneko-lua-language-server
    # language servers
    nil
    # useful tools
    git
    nmap
    #
    age
    home-manager
    nix
    # https://discourse.nixos.org/t/how-to-run-nixos-rebuild-target-host-from-darwin/9488/3
    nixos-rebuild
    sops
    ssh-to-age
  ];
}
