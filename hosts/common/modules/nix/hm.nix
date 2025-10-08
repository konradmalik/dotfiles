{ config, lib, ... }:
let
  # Map registries to channels
  # very useful when using legacy commands (they use NIX_PATH and this is what we are building here)
  # also make sure that no imperative channels are in use: nix-channel --list should be empty
  # this happens by default in flake-based nixos systems, but here we have a generic linux
  nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
in
{
  imports = [ ./shared ];
  home.sessionVariables.NIX_PATH = "${lib.concatStringsSep ":" nixPath}$\{NIX_PATH:+:$NIX_PATH}";
}
