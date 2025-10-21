{
  imports = [ ./shared/workstation.nix ];

  services.swayosd = {
    enable = true;
    topMargin = 0.5;
  };
}
