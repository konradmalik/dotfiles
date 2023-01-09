{
  description = "NixOS systems and tools by konradmalik";

  inputs =
    {
      nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
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
      klucznik = {
        url = "github:konradmalik/klucznik";
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
    , klucznik
    }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      overlay = final: prev: {
        unstable = import nixpkgs-unstable {
          system = final.system;
          config = final.config;
        };
        master = import nixpkgs-master {
          system = final.system;
          config = final.config;
        };
        dotfiles = ./files;
        klucznik = klucznik.packages.${prev.system}.klucznik;
        # workaround for rpi4 kernel:
        # https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
        makeModulesClosure = x:
          prev.makeModulesClosure (x // { allowMissing = true; });
      } // (import ./nix/overlays/default.nix) final prev;

      mkNixpkgs = { source, system, extraOverlays ? [ ] }:
        import source {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [ overlay ] ++ extraOverlays;
        };
    in
    {
      templates = import ./nix/templates;

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix { };
      });

      darwinConfigurations = {
        mbp13 =
          let
            system = "x86_64-darwin";
            username = "konrad";
            pkgs = mkNixpkgs {
              inherit system;
              source = nixpkgs-darwin;
            };
          in
          darwin.lib.darwinSystem {
            inherit system pkgs;
            specialArgs = { inherit username; };
            modules = [
              sops-nix.nixosModules.sops
              ./nix/hosts/mbp13.nix
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = import ./nix/home/mbp13.nix;
                home-manager.extraSpecialArgs = { inherit username; };
              }
            ];
          };
      };

      nixosConfigurations = {
        m3800 =
          let
            system = "x86_64-linux";
            username = "konrad";
            pkgs = mkNixpkgs {
              inherit system;
              source = nixpkgs;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit system pkgs;
            specialArgs = { inherit username; };
            modules = [
              nixos-hardware.nixosModules.common-cpu-intel
              nixos-hardware.nixosModules.common-gpu-nvidia-disable
              nixos-hardware.nixosModules.common-pc-laptop-ssd
              ./nix/hosts/m3800.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = import ./nix/home/m3800.nix;
                home-manager.extraSpecialArgs = { inherit username; };
              }
            ];
          };

        xps12 =
          let
            system = "x86_64-linux";
            username = "konrad";
            pkgs = mkNixpkgs {
              inherit system;
              source = nixpkgs;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit system pkgs;
            specialArgs = { inherit username; };
            modules = [
              nixos-hardware.nixosModules.common-cpu-intel-cpu-only
              nixos-hardware.nixosModules.common-pc-ssd
              ./nix/hosts/xps12.nix
              home-manager.nixosModules.home-manager
              sops-nix.nixosModules.sops
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = import ./nix/home/xps12.nix;
                home-manager.extraSpecialArgs = { inherit username; };
              }
            ];
          };

        vaio =
          let
            system = "x86_64-linux";
            username = "konrad";
            pkgs = mkNixpkgs {
              inherit system;
              source = nixpkgs;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit system pkgs;
            specialArgs = { inherit username; };
            modules = [
              nixos-hardware.nixosModules.common-cpu-intel-cpu-only
              nixos-hardware.nixosModules.common-pc-ssd
              sops-nix.nixosModules.sops
              ./nix/hosts/vaio.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = import ./nix/home/vaio.nix;
                home-manager.extraSpecialArgs = { inherit username; };
              }
            ];
          };

        rpi4-1 =
          let
            system = "aarch64-linux";
            username = "konrad";
            pkgs = mkNixpkgs {
              inherit system;
              source = nixpkgs;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit system pkgs;
            specialArgs = { inherit username; };
            modules = [
              nixos-hardware.nixosModules.raspberry-pi-4
              sops-nix.nixosModules.sops
              ./nix/hosts/rpi4-1.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = import ./nix/home/rpi4-1.nix;
                home-manager.extraSpecialArgs = { inherit username; };
              }
            ];
          };

        rpi4-2 =
          let
            system = "aarch64-linux";
            username = "konrad";
            pkgs = mkNixpkgs {
              inherit system;
              source = nixpkgs;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit system pkgs;
            specialArgs = { inherit username; };
            modules = [
              nixos-hardware.nixosModules.raspberry-pi-4
              sops-nix.nixosModules.sops
              ./nix/hosts/rpi4-2.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = import ./nix/home/rpi4-2.nix;
                home-manager.extraSpecialArgs = { inherit username; };
              }
            ];
          };

        installerIso =
          let
            system = "x86_64-linux";
            username = "konrad";
            pkgs = mkNixpkgs {
              inherit system;
              source = nixpkgs;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit system pkgs;
            specialArgs = { inherit username; };
            modules = [
              ./nix/iso/installer.nix
            ];
          };
      };

      homeConfigurations = {
        "konrad@linux" =
          let
            system = "x86_64-linux";
            username = "konrad";
            pkgs = mkNixpkgs {
              inherit system;
              source = nixpkgs;
            };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ ./nix/home/linux.nix ];
            extraSpecialArgs = { inherit username; };
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
