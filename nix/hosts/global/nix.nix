{ pkgs, ... }:
{
  nix = {
    # gets propagated to home-manager
    package = pkgs.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
      keep-derivations = true;
      keep-outputs = true;
    };
  };
}
