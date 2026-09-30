{
  imports = [ ../../system/profiles/darwin.nix ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  home-manager.users.konrad.imports = [ ./home.nix ];

  networking =
    let
      name = "m4";
    in
    {
      computerName = name;
      hostName = name;
    };
}
