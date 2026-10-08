{
  description = "NixOS and nix-darwin systems and tools by konradmalik";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    disko = {
      url = "github:nix-community/disko";
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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim.url = "github:konradmalik/neovim-flake";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://konradmalik.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
      "konradmalik.cachix.org-1:9REXmCYRwPNL0kAB0IMeTxnMB1Gl9VY5I8w7UVBTtSI="
    ];
  };

  outputs =
    { self, ... }@inputs:
    let

      forAllSystems =
        function:
        inputs.nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ] (system: function inputs.nixpkgs.legacyPackages.${system});

      hyprlandDir = "home/modules/desktop/hyprland";
      quickshellDir = "home/modules/desktop/quickshell";

      treefmtFor = pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      specialArgs = {
        inherit inputs;
      };
    in
    {
      devShells = forAllSystems (
        pkgs:
        let
          getSystem = attr: attr.${pkgs.stdenvNoCC.hostPlatform.system};
          darwinPackages = builtins.attrValues (removeAttrs (getSystem inputs.darwin.packages) [ "default" ]);
          hyprlandLuarc = pkgs.callPackage ./${hyprlandDir}/luarc.nix { };
          hyprlandLuaLint = pkgs.callPackage ./${hyprlandDir}/lint.nix { };
          qmlTools = pkgs.callPackage ./${quickshellDir}/qml-tools.nix { };
          qmlLint = pkgs.callPackage ./${quickshellDir}/lint.nix { };
          treefmt = (treefmtFor pkgs).config.build;
        in
        {
          default = pkgs.mkShellNoCC {
            NIX_CONFIG = "extra-experimental-features = nix-command flakes";

            name = "dotfiles";

            shellHook =
              # bash
              ''
                ln -fs ${hyprlandLuarc} ./${hyprlandDir}/.luarc.json
              ''
              +
                pkgs.lib.optionalString pkgs.stdenvNoCC.hostPlatform.isLinux
                  # bash
                  ''
                    # the shell's own `qs.*` modules live under this directory, and
                    # the qml tools resolve them only if it is an import path
                    export QML_IMPORT_PATH="$PWD/${quickshellDir}''${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
                  '';

            packages = [
              hyprlandLuaLint
              treefmt.wrapper
            ]
            ++ builtins.attrValues treefmt.programs
            ++ (with pkgs; [
              age
              git
              home-manager
              nmap
              sops
              ssh-to-age
            ])
            ++ pkgs.lib.optionals pkgs.stdenvNoCC.hostPlatform.isDarwin darwinPackages
            ++ pkgs.lib.optionals pkgs.stdenvNoCC.hostPlatform.isLinux [
              (getSystem inputs.disko.packages).disko
              qmlTools
              qmlLint
            ];
          };
        }
      );

      darwinConfigurations = {
        m4 = inputs.darwin.lib.darwinSystem {
          inherit specialArgs;
          modules = [ ./hosts/m4 ];
        };
      };

      nixosConfigurations =
        let
          x1c6IntelCompute = {
            nixpkgs.overlays = [
              # FIXME: broken on unstable
              (final: prev: {
                intel-compute-runtime-legacy1 = final.stable.intel-compute-runtime-legacy1;
              })
            ];
          };

          rpiNodejs = {
            nixpkgs.overlays = [
              # FIXME: broken on aarch64 on unstable
              (final: prev: { nodejs_latest = prev.nodejs_24; })
            ];
          };
        in
        {
          framework = inputs.nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = [ ./hosts/framework ];
          };
          rpi4-1 = inputs.nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = [
              ./hosts/rpi4-1
              rpiNodejs
            ];
          };
          rpi4-2 = inputs.nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = [
              ./hosts/rpi4-2
              rpiNodejs
            ];
          };
          x1c6 = inputs.nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = [
              ./hosts/x1c6
              x1c6IntelCompute
            ];
          };
        };

      packages = forAllSystems (
        pkgs:
        let
          custom = import ./pkgs pkgs;
        in
        custom.fonts
        // custom.scripts
        // pkgs.lib.optionalAttrs (pkgs.stdenvNoCC.hostPlatform.isLinux) (
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
            rpi4-1-sd-image =
              (self.nixosConfigurations.rpi4-1.extendModules { inherit modules; }).config.system.build.sdImage;
            rpi4-2-sd-image =
              (self.nixosConfigurations.rpi4-2.extendModules { inherit modules; }).config.system.build.sdImage;
          }
        )
      );

      checks = forAllSystems (
        pkgs:
        let
          hyprlandLuaLint = pkgs.callPackage ./${hyprlandDir}/lint.nix { };
          qmlLint = pkgs.callPackage ./${quickshellDir}/lint.nix { };
        in
        {
          formatting = (treefmtFor pkgs).config.build.check self;

          lint-lua = pkgs.runCommandLocal "lint-lua" { nativeBuildInputs = [ hyprlandLuaLint ]; } ''
            export HOME=$TMPDIR
            hyprland-lua-lint ${./${hyprlandDir}}
            touch $out
          '';
        }
        // pkgs.lib.optionalAttrs pkgs.stdenvNoCC.hostPlatform.isLinux {
          lint-qml = pkgs.runCommandLocal "lint-qml" { nativeBuildInputs = [ qmlLint ]; } ''
            export HOME=$TMPDIR
            quickshell-lint ${./${quickshellDir}}
            touch $out
          '';

          blocky = pkgs.callPackage ./system/modules/blocky.test.nix { };
          healthcheck = pkgs.callPackage ./system/options/healthcheck.test.nix { };
          monitoring = pkgs.callPackage ./system/modules/monitoring/monitoring.test.nix { };
          restic = pkgs.callPackage ./home/options/restic/restic.test.nix { inherit inputs; };
        }
      );

      templates = import ./templates;

      formatter = forAllSystems (pkgs: (treefmtFor pkgs).config.build.wrapper);
    };
}
