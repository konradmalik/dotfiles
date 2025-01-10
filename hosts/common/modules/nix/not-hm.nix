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
      lib.optionalAttrs (pkgs.stdenvNoCC.isLinux) {
        automatic = true;
        dates = [ "Fri *-*-* 10:00:00" ];
      }
      // lib.optionalAttrs (pkgs.stdenvNoCC.isDarwin) {
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
  };
  # Make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
  environment.etc."nix/inputs/nixpkgs".source = "${inputs.nixpkgs}";
}
