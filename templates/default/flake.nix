{
  description = "Development environment for this project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    inputs:
    let
      forAllSystems =
        function:
        inputs.nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ]
          (
            system:
            function (
              import inputs.nixpkgs {
                inherit system;
                overlays = [
                ];
              }
            )
          );
    in
    {
      devShells = forAllSystems (
        pkgs:
        pkgs.mkShell {
          name = "Shell for this project";
          packages = [ pkgs.hello ];
        }
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
    };
}
