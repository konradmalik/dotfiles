{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/macos-builder.nix"
  ];

  system = {
    name = "darwin-docker";
    stateVersion = "24.05";
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        flags = [ "--all" ];
        dates = "weekly";
      };
    };
    forwardPorts = [
      { from = "host"; guest.port = 22; host.port = 2376; }
    ];
  };
}
