{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  nix = {
    # should be >= max-jobs
    nrBuildUsers = 16;

    optimise =
      {
        automatic = true;
      }
      // lib.optionalAttrs (pkgs.stdenvNoCC.isLinux) {
        dates = [ "Fri *-*-* 10:00:00" ];
      }
      // lib.optionalAttrs (pkgs.stdenvNoCC.isDarwin) {
        interval = [
          {
            Hour = 10;
            Minute = 0;
            Weekday = 5;
          }
        ];
      };
  };
  # Make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
  environment.etc."nix/inputs/nixpkgs".source = "${inputs.nixpkgs}";
}
