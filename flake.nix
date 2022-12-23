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
    klucznik = {
      url = "github:konradmalik/klucznik";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles-private = {
      url = "git+ssh://git@github.com/konradmalik/dotfiles-private";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-darwin, nixpkgs-unstable, flake-utils, darwin, home-manager, klucznik, dotfiles-private }:
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

      darwin-zsh-completions-overlay = (self: super: {
        darwin-zsh-completions = super.runCommandNoCC "darwin-zsh-completions-0.0.0"
          { preferLocalBuild = true; }
          ''
            mkdir -p $out/share/zsh/site-functions
            cat <<-'EOF' > $out/share/zsh/site-functions/_darwin-rebuild
            #compdef darwin-rebuild
            #autoload
            _nix-common-options
            local -a _1st_arguments
            _1st_arguments=(
              'switch:Build, activate, and update the current generation'\
              'build:Build without activating or updating the current generation'\
              'check:Build and run the activation sanity checks'\
              'changelog:Show most recent entries in the changelog'\
            )
            _arguments \
              '--list-generations[Print a list of all generations in the active profile]'\
              '--rollback[Roll back to the previous configuration]'\
              {--switch-generation,-G}'[Activate specified generation]'\
              '(--profile-name -p)'{--profile-name,-p}'[Profile to use to track current and previous system configurations]:Profile:_nix_profiles'\
              '1:: :->subcmds' && return 0
            case $state in
              subcmds)
                _describe -t commands 'darwin-rebuild subcommands' _1st_arguments
              ;;
            esac
            EOF
          '';
      });

      mkNixpkgs = { source, system, optionalOverlays ? [ ] }:
        import source {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [ unstable-overlay yaml-overlay dotfiles-private-overlay ] ++ optionalOverlays;
        };
    in
    {
      darwinConfigurations = {
        mbp13 =
          let
            system = "x86_64-darwin";
            pkgs = mkNixpkgs { source = nixpkgs-darwin; optionalOverlays = [ darwin-zsh-completions-overlay ]; inherit system; };
          in
          darwin.lib.darwinSystem {
            inherit system pkgs;
            inputs = {
              inherit darwin;
            };
            modules = [
              ./nix/hosts/mbp13.nix
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

      nixosConfigurations = {
        m3800 =
          let
            system = "x86_64-linux";
            pkgs = mkNixpkgs { source = nixpkgs; inherit system; };
          in
          nixpkgs.lib.nixosSystem {
            inherit system pkgs;
            modules = [
              ./nix/hosts/m3800.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.konrad = import ./nix/home/konrad/m3800.nix;
                home-manager.extraSpecialArgs = { inherit dotfiles dotfiles-private; };
              }
            ];
          };
      };

      homeConfigurations = {
        "konrad@generic" =
          let
            system = "x86_64-linux";
            pkgs = mkNixpkgs { source = nixpkgs; inherit system; };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./nix/home/konrad/generic.nix
            ];
            extraSpecialArgs = { inherit dotfiles dotfiles-private; };
          };
      };
    } //

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
