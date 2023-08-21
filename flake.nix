{
  description = "NixOS and nix-darwin systems and tools by konradmalik";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-source = {
      url = "github:neovim/neovim/release-0.9?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    neovim = {
      url = "github:konradmalik/neovim-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        neovim.follows = "neovim-source";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-darwin
    , nixpkgs-unstable
    , nixpkgs-master
    , darwin
    , nixos-hardware
    , disko
    , neovim
    , home-manager
    , sops-nix
    , nix-colors
    , hyprland
    , ...
    }@inputs:
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
        ]
          (system:
            function (import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }));

      specialArgs = {
        inherit inputs;
        customArgs = {
          inherit (self) homeManagerModules nixosModules overlays;
          dotfiles = ./files;
        };
      };
    in
    {
      devShells = forAllSystems
        (pkgs: {
          default = pkgs.mkShell
            {
              name = "dotfiles";
              # Enable experimental features without having to specify the argument
              NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";
              packages = with pkgs; [
                # linters,formatters
                nixpkgs-fmt
                # language servers
                nil
                # useful tools
                manix
                nmap
                # necessary tools
                age
                git
                pkgs.home-manager
                nix
                # https://discourse.nixos.org/t/how-to-run-nixos-rebuild-target-host-from-darwin/9488/3
                nixos-rebuild
                sops
                ssh-to-age
              ];
            };
        });
      packages = forAllSystems (pkgs: (import ./pkgs { inherit pkgs; }
        // pkgs.lib.optionalAttrs (pkgs.stdenvNoCC.isLinux)
        (
          let
            rpiSdCard = "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix";
          in
          {
            installer-iso = import ./pkgs/special/installer-iso { inherit pkgs specialArgs; };
            rpi4-1-sd-image = (self.nixosConfigurations.rpi4-1.extendModules {
              modules = [ rpiSdCard ];
            }).config.system.build.sdImage;
            rpi4-2-sd-image = (self.nixosConfigurations.rpi4-2.extendModules {
              modules = [ rpiSdCard ];
            }).config.system.build.sdImage;
          }
        )
        // pkgs.lib.optionalAttrs (pkgs.stdenvNoCC.isDarwin)
        (
          let
            hostPkgs = nixpkgs-darwin.legacyPackages.${pkgs.system};
            toGuest = builtins.replaceStrings [ "darwin" ] [ "linux" ];
            guestPkgs = nixpkgs.legacyPackages.${toGuest pkgs.system};
          in
          {
            darwin-builder = import ./pkgs/special/darwin-builder { inherit hostPkgs guestPkgs; };
            darwin-devnix = import ./pkgs/special/darwin-devnix { inherit hostPkgs guestPkgs specialArgs; };
            darwin-docker = import ./pkgs/special/darwin-docker { inherit hostPkgs guestPkgs; };
          }
        )));
      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);

      homeManagerModules = import ./modules/home-manager;
      nixosModules = import ./modules/nixos;
      overlays = import ./overlays;
      templates = import ./templates;

      darwinConfigurations = {
        mbp13 = darwin.lib.darwinSystem {
          inherit specialArgs;
          inputs = nixpkgs.lib.overrideExisting inputs { nixpkgs = nixpkgs-darwin; };
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
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = specialArgs;
          modules = [ ./home/konrad/generic.nix ];
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
