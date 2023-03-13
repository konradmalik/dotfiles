{
  description = "Development environment for this project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      mkOverlay = input: name: (final: prev: {
        "${name}" = import input {
          system = final.system;
          config = final.config;
        };
      });
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          overlays = [
            (mkOverlay nixpkgs-unstable "unstable")
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
                name = "Shell for this project";

                packages = with pkgs; [
                  # formatters/linters
                  nixpkgs-fmt
                  # language-servers
                  nil
                ];
              };
          });
      formatter = forAllSystems (system:
        let pkgs = pkgsFor system;
        in pkgs.nixpkgs-fmt);
    };
}
