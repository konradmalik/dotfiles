{
  imports = [
    ../profiles/server.nix

    ../modules/monitoring/agents.nix
  ];

  konrad.services.syncthing = {
    enable = true;
    user = "konrad";
    bidirectional = false;
  };
}
