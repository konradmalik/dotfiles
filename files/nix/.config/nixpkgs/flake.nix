{
  description = "Konrad's home flake";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/release-22.11;
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixpkgs-unstable;
    home-manager = {
      url = github:nix-community/home-manager/release-22.11;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager }:
    {
      homeConfigurations = {
        "konrad@m3800" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [
            ./home.nix
          ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
        };
      };
    };
}
