{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    autoPrune = {
      enable = true;
      flags = [ "--all" ];
      dates = "weekly";
    };
  };
}
