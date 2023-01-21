let
  flakeLock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgsLock = flakeLock.nodes.nixpkgs.locked;
  deployRsLock = flakeLock.nodes.deploy-rs.locked;
  lockedNixpkgs = import
    (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgsLock.rev}.tar.gz";
      sha256 = nixpkgsLock.narHash;
    })
    { };
  lockedDeployRs = import
    (fetchTarball {
      url = "https://github.com/serokell/deploy-rs/archive/${deployRsLock.rev}.tar.gz";
      sha256 = deployRsLock.narHash;
    })
    { };
in
{ pkgs ? lockedNixpkgs, deploy-rs ? lockedDeployRs }:
with pkgs;
mkShell {
  name = "dotfiles-shell";

  # Enable experimental features without having to specify the argument
  NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";

  nativeBuildInputs = [
    git
    nmap
    # nix
    nix
    nil
    nixpkgs-fmt
    home-manager
    deploy-rs
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
