{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  nixpkgs = {
    overlays = [
      (
        final: prev:
        (import ../../../../pkgs/installable { pkgs = final; })
        // {
          baywatch = inputs.baywatch.packages.${final.system}.bwatch;
          stable = import inputs.nixpkgs-stable {
            system = final.system;
            config = final.config;
          };
        }
      )
    ];
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };
  };
  nix =
    {
      package = pkgs.nixVersions.latest;
      settings = {
        auto-optimise-store = lib.mkDefault true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        keep-derivations = true;
        keep-outputs = true;
        trusted-users =
          [ "root" ]
          ++ lib.optional pkgs.stdenvNoCC.isLinux "@wheel" ++ lib.optional pkgs.stdenvNoCC.isDarwin "@admin";
        extra-substituters = [
          "https://konradmalik.cachix.org"
          "https://nix-community.cachix.org"
        ];
        extra-trusted-public-keys = [
          "konradmalik.cachix.org-1:9REXmCYRwPNL0kAB0IMeTxnMB1Gl9VY5I8w7UVBTtSI="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
        ];
        min-free = lib.mkDefault (10 * 1000 * 1000 * 1000); # 10gb
        cores = lib.mkDefault 0;
        max-jobs = lib.mkDefault "auto";
      };
    }
    # below does not exist in plain home-manager
    # but it will work for nixos config and for nix-darwin config
    # this check is needed because of generic linux entry in homeConfigurations
    // lib.optionalAttrs (builtins.hasAttr "nrBuildUsers" config.nix) {
      # should be >= max-jobs
      nrBuildUsers = 16;
    };
}
