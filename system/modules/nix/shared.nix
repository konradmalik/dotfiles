{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  nixpkgs = {
    overlays = [
      (final: prev: {
        stable = import inputs.nixpkgs-stable {
          inherit (prev.stdenv.hostPlatform) system;
        };
        custom = import ../../../pkgs final;
      })
    ];
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };
  };
  nix = {
    package = pkgs.nixVersions.latest;

    # should be >= max-jobs
    nrBuildUsers = 16;

    registry = {
      # Setting only non standards here. Eg. "nixpkgs" is set by default.
      nixpkgs-stable.flake = inputs.nixpkgs-stable;
    };

    optimise =
      lib.optionalAttrs (pkgs.stdenvNoCC.hostPlatform.isLinux) {
        automatic = true;
        dates = [ "Fri *-*-* 10:00:00" ];
      }
      // lib.optionalAttrs (pkgs.stdenvNoCC.hostPlatform.isDarwin) {
        # TODO problems with sysctld high cpu usage?
        # just disable this
        automatic = false;
        interval = [
          {
            Hour = 10;
            Minute = 0;
            Weekday = 5;
          }
        ];
      };

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      keep-derivations = true;
      keep-outputs = true;
      trusted-users = [
        "root"
      ]
      ++ lib.optional pkgs.stdenvNoCC.hostPlatform.isLinux "@wheel"
      ++ lib.optional pkgs.stdenvNoCC.hostPlatform.isDarwin "@admin";
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
  };

  # Make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
  environment.etc."nix/inputs/nixpkgs".source = "${inputs.nixpkgs}";
}
