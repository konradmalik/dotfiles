{ inputs, ... }:
{
  imports = [
    inputs.stylix.darwinModules.stylix
    ./shared.nix
  ];
}
