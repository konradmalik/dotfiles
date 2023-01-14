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
  NIX_CONFIG = "experimental-features = nix-command flakes";

  nativeBuildInputs = [
    git
    nmap
    # nix
    nix
    home-manager
    nil
    nixpkgs-fmt
    # https://discourse.nixos.org/t/how-to-run-nixos-rebuild-target-host-from-darwin/9488/3
    nixos-rebuild
    # lua (neovim)
    sumneko-lua-language-server
    # yaml
    nodePackages.yaml-language-server
    # sops-nix
    age
    sops
    ssh-to-age
  ];
}
