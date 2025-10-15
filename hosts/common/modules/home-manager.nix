{ inputs, ... }:

{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
    };
  };
}
