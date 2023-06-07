{ pkgs, lib }:
pkgs.mkShell {
  name = "dotfiles-shell";

  # Enable experimental features without having to specify the argument
  NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";

  packages = with pkgs; [
    # linters,formatters
    nixpkgs-fmt
    # language servers
    nodePackages.yaml-language-server
    sumneko-lua-language-server
    nil
    # useful tools
    manix
    nmap
    # necessary tools
    age
    git
    home-manager
    nix
    # https://discourse.nixos.org/t/how-to-run-nixos-rebuild-target-host-from-darwin/9488/3
    nixos-rebuild
    sops
    ssh-to-age
  ];
}
