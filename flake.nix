{
  description = "NixOS systems and tools by konradmalik";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-22.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    klucznik = {
      url = "github:konradmalik/klucznik";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles-private = {
      url = "git+ssh://git@github.com/konradmalik/dotfiles-private";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-darwin
    , nixpkgs-unstable
    , flake-utils
    , darwin
    , home-manager
    , nixos-generators
    , klucznik
    , dotfiles-private
    }:
    let
      overlays = [
        (final: prev: {
          unstable = import nixpkgs-unstable {
            system = final.system;
            config = final.config;
          };
          dotfiles = ./files;
          dotfiles-private = dotfiles-private.packages.${prev.system}.default;
          klucznik = klucznik.packages.${prev.system}.klucznik;
        })
        (import ./nix/overlays)
      ];

      mkNixpkgs = { source, system, extraOverlays ? [ ] }:
        import source {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = overlays
            ++ extraOverlays;
        };

      m3800Config =
        let
          system = "x86_64-linux";
          username = "konrad";
          pkgs = mkNixpkgs {
            inherit system;
            source = nixpkgs;
          };
        in
        {
          inherit system pkgs;
          specialArgs = { inherit username; };
          modules = [
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
    in
    {
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
        m3800 = nixpkgs.lib.nixosSystem m3800Config;
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

      packages.x86_64-linux =
        {
          m3800iso = nixos-generators.nixosGenerate (m3800Config // { format = "iso"; });
        };
    }
    //
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      devShells.default = pkgs.callPackage ./shell.nix { };
    }
    );
}
