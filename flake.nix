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
        inputs.nixpkgs.follows = "nixpkgs";
      };
      nix-colors.url = "github:misterio77/nix-colors";
      hyprland.url = "github:hyprwm/Hyprland/v0.20.1beta";

      deploy-rs = {
        url = "github:serokell/deploy-rs";
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
    , nix-colors
    , hyprland
    , deploy-rs
    }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
      inherit (self) outputs;
      specialArgs = { inherit inputs outputs; };
    in
    {
      homeManagerModules = import ./nix/modules/home-manager;
      packages = forAllSystems (system:
        import ./nix/pkgs { pkgs = pkgsFor system; }
      );
      templates = import ./nix/templates;
      devShells = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          default = pkgs.callPackage ./shell.nix { inherit pkgs deploy-rs; };
        });
      overlays = import ./nix/overlays;

      darwinConfigurations = {
        mbp13 = darwin.lib.darwinSystem {
          inputs = nixpkgs.lib.overrideExisting inputs { nixpkgs = nixpkgs-darwin; };
          specialArgs = { inherit inputs outputs; };
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
          modules = [ ./nix/iso/installer ];
        };
      };

      homeConfigurations = {
        "konrad@generic" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = specialArgs;
          modules = [ ./nix/home/konrad/generic.nix ];
        };
      };

      deploy = {
        nodes = {
          m3800 = {
            hostname = "m3800";
            profiles.system = {
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.m3800;
            };
          };
          vaio = {
            hostname = "vaio";
            profiles.system = {
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.vaio;
            };
          };
          xps12 = {
            hostname = "xps12";
            profiles.system = {
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.xps12;
            };
          };
          rpi4-1 = {
            hostname = "rpi4-1";
            profiles.system = {
              path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.rpi4-1;
            };
          };
          rpi4-2 = {
            hostname = "rpi4-2";
            profiles.system = {
              path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.rpi4-2;
            };
          };
        };

        magicRollback = true;
        autoRollback = true;
        remoteBuild = true;
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
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
