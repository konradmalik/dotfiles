{
  description = "NixOS systems and tools by konradmalik";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/release-22.11;
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixpkgs-unstable;
    nixpkgs-darwin.url = github:NixOS/nixpkgs/nixpkgs-22.11-darwin;

    darwin = {
      url = github:lnl7/nix-darwin;
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = github:nix-community/home-manager/release-22.11;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-darwin, darwin, home-manager }:
    {
      darwinConfigurations = {
        "konrad@mbp13" =
          let
            system = "x86_64-darwin";
            nixpkgs = nixpkgs-darwin;
          in
          darwin.lib.darwinSystem {
            inherit system;
            inputs = {
              inherit nixpkgs darwin;
            };
            modules = [
              ./nix/hosts/mbp13
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.konrad = import ./nix/home/konrad/mbp13.nix;
                # user home-manager.extraSpecialArgs to pass arguments to home.nix
              }
            ];
          };
      };

      homeConfigurations = {
        "konrad@m3800" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./nix/home/konrad/m3800.nix
          ];
        };
      };
    };
}
