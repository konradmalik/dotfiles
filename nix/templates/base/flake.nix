{
  description = "foo flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-compat }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              unstable = import nixpkgs-unstable {
                system = final.system;
                config = final.config;
              };
            })
          ];
        };
    in
    {
      devShells = forAllSystems
        (system:
          let pkgs = pkgsFor system;
          in
          {
            default = pkgs.mkShell
              {
                name = "foo-shell";

                nativeBuildInputs = [
                  # nix
                  pkgs.nil
                  pkgs.nixpkgs-fmt
                ];
              };
          });
    };
}
