{ inputs, ... }:
{
  # should be >= max-jobs
  nix.nrBuildUsers = 16;
  # Make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
  environment.etc."nix/inputs/nixpkgs".source = "${inputs.nixpkgs}";
}
