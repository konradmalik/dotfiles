{
  imports = [ ../../system/profiles/darwin.nix ];

  home-manager.users.konrad.imports = [ ./home.nix ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking =
    let
      name = "m4";
    in
    {
      computerName = name;
      hostName = name;
    };
}
