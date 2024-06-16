{ inputs, ... }:
let
  specialArgs = {
    inherit inputs;
    customArgs = {
      files = ./../files;
    };
  };
in
{
  imports = [
    ./checks.nix
    ./devshells.nix
    ./packages.nix
  ];

  flake = {
    templates = import ./templates;

    darwinConfigurations = {
      mbp13 = inputs.darwin.lib.darwinSystem {
        inherit specialArgs;
        modules = [ ./hosts/mbp13 ];
      };
    };

    nixosConfigurations = {
      m3800 = inputs.nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [ ./hosts/m3800 ];
      };
      xps12 = inputs.nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [ ./hosts/xps12 ];
      };
      vaio = inputs.nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [ ./hosts/vaio ];
      };
      rpi4-1 = inputs.nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [ ./hosts/rpi4-1 ];
      };
      rpi4-2 = inputs.nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [ ./hosts/rpi4-2 ];
      };
    };

    homeConfigurations = {
      "konrad@generic" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = specialArgs;
        modules = [ ./home/konrad/generic.nix ];
      };
    };
  };

  perSystem =
    { system, pkgs, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ ];
      };

      formatter = pkgs.nixfmt-rfc-style;
    };
}
