{ inputs, customArgs, ... }:
{
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs customArgs; };
  };
}
