{
  imports = [ ./shared/workstation.nix ];

  programs.light.enable = true;
  services.thermald.enable = true;
  services.tlp.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  services.upower = {
    enable = true;
    percentageLow = 25;
    percentageCritical = 15;
    percentageAction = 10;
    criticalPowerAction = "Suspend";
    # needed for Suspend
    allowRiskyCriticalPowerAction = true;
  };
}
