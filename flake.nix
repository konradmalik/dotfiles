{
  description = "NixOS systems and tools by konradmalik";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/release-22.11;
    nixpkgs-darwin.url = github:NixOS/nixpkgs/nixpkgs-22.11-darwin;
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixpkgs-unstable;

    darwin = {
      url = github:lnl7/nix-darwin;
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = github:nix-community/home-manager/release-22.11;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    klucznik = {
      url = github:konradmalik/klucznik;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles-private = {
      url = git+ssh://git@github.com/konradmalik/dotfiles-private;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-darwin, nixpkgs-unstable, darwin, home-manager, klucznik, dotfiles-private }:
    let
      unstable-overlay = final: prev: {
        unstable = import nixpkgs-unstable {
          system = final.system;
          config = final.config;
        };
      };
      klucznik-overlay = final: prev: {
        klucznik = klucznik.packages.${prev.system}.klucznik;
      };
      dotfiles-private-overlay = final: prev: {
        dotfiles-private = dotfiles-private.packages.${prev.system}.default;
      };
      dotfiles = ./files;

      yaml-overlay = final: prev:
        let
          fromYAML = yaml: builtins.fromJSON (
            builtins.readFile (
              final.runCommand "from-yaml"
                {
                  inherit yaml;
                  allowSubstitutes = false;
                  preferLocalBuild = true;
                }
                ''
                  ${final.remarshal}/bin/remarshal  \
                    -if yaml \
                    -i <(echo "$yaml") \
                    -of json \
                    -o $out
                ''
            )
          );

          readYAML = path: fromYAML (builtins.readFile path);
        in
        {
          lib = prev.lib // {
            inherit fromYAML readYAML;
          };
        };

      mkNixpkgs = source: system:
        import source {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [ unstable-overlay yaml-overlay dotfiles-private-overlay ];
        };
    in
    {
      darwinConfigurations = {
        "konrad@mbp13" =
          let
            system = "x86_64-darwin";
            pkgs = mkNixpkgs nixpkgs-darwin system;
          in
          darwin.lib.darwinSystem {
            inherit system pkgs;
            inputs = {
              inherit darwin;
            };
            modules = [
              ./nix/hosts/mbp13
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.konrad = import ./nix/home/konrad/mbp13.nix;
                home-manager.extraSpecialArgs = { inherit dotfiles dotfiles-private; };
              }
            ];
          };
      };

      homeConfigurations = {
        "konrad@m3800" =
          let
            system = "x86_64-linux";
            pkgs = mkNixpkgs nixpkgs system;
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./nix/home/konrad/m3800.nix
            ];
            extraSpecialArgs = { inherit dotfiles dotfiles-private; };
          };
      };
    };
}
