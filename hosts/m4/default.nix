{
  imports = [ ../../system/profiles/darwin.nix ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  home-manager.users.konrad.imports = [ ./home.nix ];

  networking.hostName = "m4";
}
