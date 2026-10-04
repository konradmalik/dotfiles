{
  imports = [ ../../system/profiles/darwin.nix ];

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
