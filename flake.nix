{
  description = "NixOS systems and tools by konradmalik";

  inputs =
    {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
      nixpkgs-master.url = "github:NixOS/nixpkgs/master";
      nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-22.11-darwin";
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
      nixos-hardware.url = "github:NixOS/nixos-hardware/master";

      darwin = {
        url = "github:lnl7/nix-darwin";
        inputs.nixpkgs.follows = "nixpkgs-darwin";
      };
      home-manager = {
        url = "github:nix-community/home-manager/release-22.11";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      sops-nix = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-master
    , nixpkgs-darwin
    , nixpkgs-unstable
    , nixos-hardware
    , darwin
    , home-manager
    , sops-nix
    }@inputs:
    let
      username = "konrad";
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      inherit (self) outputs;
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./nix/pkgs { inherit pkgs; }
      );
      templates = import ./nix/templates;
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix { };
      });
      overlays = import ./nix/overlays;
      nixosModules = import ./nix/modules/nixos;

      darwinConfigurations = {
        mbp13 = darwin.lib.darwinSystem {
          inputs = nixpkgs.lib.overrideExisting inputs { nixpkgs = nixpkgs-darwin; };
          specialArgs = { inherit inputs outputs username; };
          modules = [ ./nix/hosts/mbp13 ];
        };
      };
      nixosConfigurations = {
        m3800 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs username; };
          modules = [ ./nix/hosts/m3800 ];
        };
        xps12 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs username; };
          modules = [ ./nix/hosts/xps12 ];
        };
        vaio = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs username; };
          modules = [ ./nix/hosts/vaio ];
        };
        rpi4-1 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs username; };
          modules = [ ./nix/hosts/rpi4-1 ];
        };
        rpi4-2 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs username; };
          modules = [ ./nix/hosts/rpi4-2 ];
        };
        installerIso = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs username; };
          modules = [
            ./nix/iso/installer
          ];
        };
      };

      homeConfigurations = {
        "konrad@generic" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./nix/home/generic.nix ];
          extraSpecialArgs = { inherit inputs outputs username; };
        };
      };
    };

  nixConfig = {
    extra-trusted-substituters = [
      "https://konradmalik.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "konradmalik.cachix.org-1:9REXmCYRwPNL0kAB0IMeTxnMB1Gl9VY5I8w7UVBTtSI="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
    ];
  };
}
