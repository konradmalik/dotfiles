{
  description = "NixOS systems and tools by konrad malik";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/release-21.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";

      # We want home-manager to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager }: let
    mkVM = import ./lib/mkvm.nix;
  in {
    nixosConfigurations.vb-darwin-intel = mkVM "vb-darwin-intel" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "konrad";
    };

    nixosConfigurations.vm-darwin-intel = mkVM "vm-darwin-intel" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "konrad";
    };
  };
}
