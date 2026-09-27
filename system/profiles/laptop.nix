{ pkgs, ... }:
{
  imports = [
    ./desktop.nix
  ];

  environment.systemPackages = [ pkgs.brightnessctl ];
  services.thermald.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  services.tlp = {
    enable = true;
    pd.enable = true;

    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
    };
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
