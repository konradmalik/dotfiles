{
  imports = [ ../systems/nixos.nix ];

  konrad.network.wireless.enable = true;
  konrad.services.autoupgrade.enable = true;

  services.logind.settings.Login.HandleLidSwitch = "ignore";
}
