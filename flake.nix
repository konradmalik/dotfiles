{
  description = "NixOS and nix-darwin systems and tools by konradmalik";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin-docker.url = "github:konradmalik/darwin-docker";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    nix-colors.url = "github:misterio77/nix-colors";

    neovim.url = "github:konradmalik/neovim-flake";
    baywatch.url = "github:konradmalik/baywatch";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      darwin,
      home-manager,
      ...
    }@inputs:
    let
      nixpkgsFor =
        system:
        (import nixpkgs {
          localSystem = {
            inherit system;
          };
        });

      forAllSystems =
        function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
        ] (system: function (nixpkgsFor system));

      specialArgs = {
        inherit inputs;
        customArgs = {
          inherit (self) homeManagerModules nixosModules overlays;
          files = ./files;
        };
      };
    in
    {
      devShells = forAllSystems (
        pkgs:
        let
          darwinPackages = builtins.attrValues (
            builtins.removeAttrs inputs.darwin.packages.${pkgs.system} [ "default" ]
          );
        in
        {
          default = pkgs.mkShell {
            NIX_CONFIG = "extra-experimental-features = nix-command flakes";

            name = "dotfiles";
            packages =
              with pkgs;
              [
                manix
                nmap
                age
                git
                pkgs.home-manager
                sops
                ssh-to-age
              ]
              ++ lib.optionals pkgs.stdenvNoCC.isDarwin darwinPackages;
          };
        }
      );
      packages = forAllSystems (
        pkgs:
        (
          import ./pkgs { inherit pkgs; }
          // pkgs.lib.optionalAttrs (pkgs.stdenvNoCC.isLinux) (
            let
              rpiSdCard = "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix";
              # https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
              missingKernelModulesFix = {
                nixpkgs.overlays = [
                  (final: prev: { makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; }); })
                ];
              };
              modules = [
                rpiSdCard
                missingKernelModulesFix
              ];
            in
            {
              installer-iso = import ./pkgs/special/installer-iso { inherit pkgs specialArgs; };
              rpi4-1-sd-image =
                (self.nixosConfigurations.rpi4-1.extendModules { inherit modules; }).config.system.build.sdImage;
              rpi4-2-sd-image =
                (self.nixosConfigurations.rpi4-2.extendModules { inherit modules; }).config.system.build.sdImage;
            }
          )
        )
      );
      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);

      homeManagerModules = import ./modules/home-manager;
      nixosModules = import ./modules/nixos;
      overlays = import ./overlays { inherit inputs; };
      templates = import ./templates;

      darwinConfigurations = {
        mbp13 = darwin.lib.darwinSystem {
          inherit specialArgs;
          modules = [ ./hosts/mbp13 ];
        };
      };

      nixosConfigurations = {
        m3800 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./hosts/m3800 ];
        };
        xps12 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./hosts/xps12 ];
        };
        vaio = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./hosts/vaio ];
        };
        rpi4-1 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./hosts/rpi4-1 ];
        };
        rpi4-2 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./hosts/rpi4-2 ];
        };
      };

      homeConfigurations = {
        "konrad@generic" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor "x86_64-linux";
          extraSpecialArgs = specialArgs;
          modules = [ ./home/konrad/generic.nix ];
        };
      };

      checks = {
        x86_64-darwin = {
          mbp13 = self.darwinConfigurations.mbp13.system;
        };
      };
    };

  nixConfig = {
    extra-substituters = [
      "https://konradmalik.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "konradmalik.cachix.org-1:9REXmCYRwPNL0kAB0IMeTxnMB1Gl9VY5I8w7UVBTtSI="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
    ];
  };
}
