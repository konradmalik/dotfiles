{
  imports = [
    ./checks.nix
    ./configurations.nix
    ./devshells.nix
    ./packages.nix
  ];

  flake = {
    templates = import ./../templates;
  };

  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-rfc-style;
    };
}
