{
  description = "NixOS and nix-darwin systems and tools by konradmalik";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-22.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-konradmalik.url = "github:konradmalik/nixpkgs/rtx";
    darwin = {
      # url = "github:lnl7/nix-darwin";
      url = "github:konradmalik/nix-darwin/uri-builder-fix";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
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
    nix-colors.url = "github:misterio77/nix-colors";
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.24.0";
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
    , darwin
    , nixos-hardware
    , disko
    , flake-utils
    , flake-compat
    , home-manager
    , sops-nix
    , nix-colors
    , hyprland
    }@inputs:
    let
      specialArgs = {
        inherit inputs;
        customArgs = {
          inherit (self) homeManagerModules nixosModules overlays;
          dotfiles = ./files;
        };
      };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells = {
          default = pkgs.callPackage ./nix/shell.nix { };
        };
        formatter = pkgs.nixpkgs-fmt;
        packages = (import ./nix/pkgs { inherit pkgs; }
        // pkgs.lib.optionalAttrs (pkgs.lib.hasSuffix "linux" system)
          (
            let
              rpiSdCard = "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix";
            in
            {
              installer-iso = import ./nix/pkgs/special/installer-iso { inherit pkgs specialArgs; };
              rpi4-1-sd-image = (self.nixosConfigurations.rpi4-1.extendModules {
                modules = [ rpiSdCard ];
              }).config.system.build.sdImage;
              rpi4-2-sd-image = (self.nixosConfigurations.rpi4-2.extendModules {
                modules = [ rpiSdCard ];
              }).config.system.build.sdImage;
            }
          )
        // pkgs.lib.optionalAttrs (pkgs.lib.hasSuffix "darwin" system)
          (
            let
              hostPkgs = nixpkgs-darwin.legacyPackages.${system};
              toGuest = builtins.replaceStrings [ "darwin" ] [ "linux" ];
              guestPkgs = nixpkgs.legacyPackages.${toGuest system};
            in
            {
              darwin-builder = import ./nix/pkgs/special/darwin-builder { inherit hostPkgs guestPkgs; };
              darwin-devnix = import ./nix/pkgs/special/darwin-devnix { inherit hostPkgs guestPkgs specialArgs; };
              darwin-docker = import ./nix/pkgs/special/darwin-docker { inherit hostPkgs guestPkgs; };
            }
          ));
      })
    //
    {
      homeManagerModules = import ./nix/modules/home-manager;
      nixosModules = import ./nix/modules/nixos;
      overlays = import ./nix/overlays;
      templates = import ./nix/templates;

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
