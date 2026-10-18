# nixos-rebuild and darwin-rebuild without --flake use the flake found here
{ config, pkgs, ... }:
let
  name = if pkgs.stdenv.hostPlatform.isDarwin then "nix-darwin" else "nixos";
in
{
  environment.etc.${name}.source = config.home-manager.users.konrad.konrad.repos.dotfiles.path;
}
