{
  description = "NixOS and nix-darwin systems and tools by konradmalik";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    darwin = {
      url = "github:nix-darwin/nix-darwin";
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
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim.url = "github:konradmalik/neovim-flake";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
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

  outputs =
    { self, ... }@inputs:
    let
      forAllSystems =
        function:
        inputs.nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
          ]
          (
            system:
            function (
              import inputs.nixpkgs {
                inherit system;
                overlays = [
                  (import ./pkgs/fonts)
                  (import ./pkgs/scripts)
                ];
              }
            )
          );

      specialArgs = {
        inherit inputs;
      };
    in
    {
      devShells = forAllSystems (
        pkgs:
        let
          getSystem = attr: attr.${pkgs.stdenvNoCC.hostPlatform.system};
          darwinPackages = builtins.attrValues (
            builtins.removeAttrs (getSystem inputs.darwin.packages) [ "default" ]
          );
        in
        {
          default = pkgs.mkShell {
            NIX_CONFIG = "extra-experimental-features = nix-command flakes";

            name = "dotfiles";
            packages =
              (with pkgs; [
                age
                git
                home-manager
                manix
                nmap
                sops
                ssh-to-age
              ])
              ++ pkgs.lib.optionals pkgs.stdenvNoCC.isDarwin darwinPackages
              ++ pkgs.lib.optionals pkgs.stdenvNoCC.isLinux [ (getSystem inputs.disko.packages).disko ];
          };
        }
      );

      darwinConfigurations = {
        mbp13 = inputs.darwin.lib.darwinSystem {
          inherit specialArgs;
          modules = [ ./hosts/mbp13 ];
        };
      };

      nixosConfigurations = {
        framework = inputs.nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./hosts/framework ];
        };
        m3800 = inputs.nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./hosts/m3800 ];
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

      packages = forAllSystems (
        pkgs:
        pkgs.fonts
        // pkgs.scripts
        // pkgs.lib.optionalAttrs (pkgs.stdenvNoCC.isLinux) (
          let
            rpiSdCard = "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix";
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
      );

      templates = import ./templates;

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
    };
}
