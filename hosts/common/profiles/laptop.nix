{
  imports = [ ./desktop.nix ];

  services.thermald.enable = true;
  services.tlp.enable = true;
}
