{ pkgs, ... }:
{
  nix = {
    package = pkgs.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
      keep-derivations = true;
      keep-outputs = true;
      substituters = [ "https://konradmalik.cachix.org" ];
      trusted-public-keys = [ "konradmalik.cachix.org-1:9REXmCYRwPNL0kAB0IMeTxnMB1Gl9VY5I8w7UVBTtSI=" ];
    };
  };
}
