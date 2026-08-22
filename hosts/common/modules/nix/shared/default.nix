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
        custom =
          ((import ../../../../../pkgs/scripts) final prev)
          // ((import ../../../../../pkgs/fonts) final prev);
      })
      # curl-impersonate's dylib kept upstream's @rpath install name on darwin,
      # so consumers (e.g. python3Packages.curl-cffi, a yt-dlp dependency)
      # fail at load time with "Library not loaded: @rpath/libcurl-impersonate.4.dylib".
      # Fixed upstream via https://github.com/NixOS/nixpkgs/commit/9da1a5ec6c87b0def6717f4c99ca499fe95ba213
      # TODO: remove this overlay once that fix reaches our nixpkgs input.
      (final: prev: {
        curl-impersonate = prev.curl-impersonate.overrideAttrs (old: {
          nativeBuildInputs =
            (old.nativeBuildInputs or [ ])
            ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [ prev.fixDarwinDylibNames ];
        });
      })
    ];
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };
  };
  nix = {
    package = pkgs.nixVersions.latest;
    registry = {
      # Setting only non standards here. Eg. "nixpkgs" is set by default.
      nixpkgs-stable.flake = inputs.nixpkgs-stable;
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
}
