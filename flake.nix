{
  description = "NixOS systems and tools by konradmalik";

  inputs =
    {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
      nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-22.11-darwin";
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
      nixpkgs-master.url = "github:NixOS/nixpkgs/master";
      nixpkgs-konradmalik.url = "github:konradmalik/nixpkgs/rtx";
      nixos-hardware.url = "github:NixOS/nixos-hardware/master";
      flake-utils.url = "github:numtide/flake-utils";

      darwin = {
        # url = "github:lnl7/nix-darwin";
        url = "github:konradmalik/nix-darwin/uri-builder-fix";
        inputs.nixpkgs.follows = "nixpkgs-darwin";
      };
      home-manager = {
        url = "github:nix-community/home-manager/release-22.11";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      sops-nix = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
        inputs.nixpkgs-stable.follows = "nixpkgs";
      };
      disko = {
        url = "github:nix-community/disko";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      nix-colors.url = "github:misterio77/nix-colors";
      hyprland = {
        url = "github:hyprwm/Hyprland/main";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
    };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-darwin
    , nixpkgs-unstable
    , nixpkgs-master
    , nixpkgs-konradmalik
    , nixos-hardware
    , flake-utils
    , darwin
    , home-manager
    , sops-nix
    , disko
    , nix-colors
    , hyprland
    }@inputs:
    let
      inherit (self) outputs;
      specialArgs = { inherit inputs outputs; };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        devShells = {
          default = pkgs.callPackage ./shell.nix { inherit pkgs; };
        };
        formatter = pkgs.nixpkgs-fmt;
        packages = (import ./nix/pkgs { inherit pkgs; }
        // pkgs.lib.optionalAttrs (pkgs.lib.hasSuffix "darwin" system)
          {
            darwin-builder = pkgs.callPackage ./nix/pkgs/special/darwin-builder.nix { inherit inputs; };
          }
        // pkgs.lib.optionalAttrs (system == "x86_64-darwin")
          {
            darwin-docker = self.nixosConfigurations.darwin-docker.config.system.build.vm;
          });
      })
    //
    {
      homeManagerModules = import ./nix/modules/home-manager;
      nixosModules = import ./nix/modules/nixos;
      templates = import ./nix/templates;
      overlays = import ./nix/overlays;

      darwinConfigurations = {
        mbp13 = darwin.lib.darwinSystem {
          inherit specialArgs;
          inputs = nixpkgs.lib.overrideExisting inputs { nixpkgs = nixpkgs-darwin; };
          modules = [ ./nix/hosts/mbp13 ];
        };
      };

      nixosConfigurations = {
        m3800 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./nix/hosts/m3800 ];
        };
        xps12 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./nix/hosts/xps12 ];
        };
        vaio = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./nix/hosts/vaio ];
        };
        rpi4-1 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./nix/hosts/rpi4-1 ];
        };
        rpi4-2 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./nix/hosts/rpi4-2 ];
        };
        installerIso = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./nix/hosts/special/installer ];
        };
        darwin-docker = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./nix/hosts/special/darwin-docker ];
        };
      };

      homeConfigurations = {
        "konrad@generic" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = specialArgs;
          modules = [ ./nix/home/konrad/generic.nix ];
        };
      };

    };

  nixConfig = {
    extra-trusted-substituters = [
      "https://konradmalik.cachix.org"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "konradmalik.cachix.org-1:9REXmCYRwPNL0kAB0IMeTxnMB1Gl9VY5I8w7UVBTtSI="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
}
