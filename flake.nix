{
  description = "NixOS systems and tools by konradmalik";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/release-22.11;
    nixpkgs-darwin.url = github:NixOS/nixpkgs/nixpkgs-22.11-darwin;
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixpkgs-unstable;
    nixpkgs-trunk.url = github:nixos/nixpkgs;

    darwin = {
      url = github:lnl7/nix-darwin;
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = github:nix-community/home-manager/release-22.11;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-darwin, nixpkgs-unstable, nixpkgs-trunk, darwin, home-manager }:
    let
      unstable-overlay = final: prev: {
        unstable = import nixpkgs-unstable {
          system = final.system;
          config = final.config;
        };
      };
      trunk-overlay =
        final: prev: {
          trunk = import nixpkgs-trunk {
            system = final.system;
            config = final.config;
          };
        };
    in
    {
      darwinConfigurations = {
        "konrad@mbp13" =
          let
            system = "x86_64-darwin";
            pkgs = import nixpkgs-darwin {
              inherit system;
              config = {
                allowUnfree = true;
              };
              overlays = [
                unstable-overlay
              ];
            };
          in
          darwin.lib.darwinSystem {
            inherit system pkgs;
            inputs = {
              inherit darwin;
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
        "konrad@m3800" =
          let
            system = "x86_64-linux";
            pkgs = import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
              };
              overlays = [
                unstable-overlay
              ];
            };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./nix/home/konrad/m3800.nix
            ];
          };
      };
    };
}
