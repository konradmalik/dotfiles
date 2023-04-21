{ inputs, outputs, dotfiles, ... }:
{
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs outputs dotfiles; };
  };
}
