{ inputs, ... }:
{
  flake =
    let
      specialArgs = {
        inherit inputs;
        customArgs = {
          files = ./../files;
        };
      };
    in
    {
      darwinConfigurations = {
        mbp13 = inputs.darwin.lib.darwinSystem {
          inherit specialArgs;
          modules = [ ./../hosts/mbp13 ];
        };
      };

      nixosConfigurations = {
        framework = inputs.nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./../hosts/framework ];
        };
        m3800 = inputs.nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./../hosts/m3800 ];
        };
        vaio = inputs.nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./../hosts/vaio ];
        };
        rpi4-1 = inputs.nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./../hosts/rpi4-1 ];
        };
        rpi4-2 = inputs.nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./../hosts/rpi4-2 ];
        };
      };

      homeConfigurations = {
        "konrad@generic" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = specialArgs;
          modules = [ ./../home/konrad/generic.nix ];
        };
      };
    };
}
