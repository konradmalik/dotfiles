{
  imports = [ ./shared/workstation.nix ];

  programs.light.enable = true;
  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "balanced";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balanced";

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 40;
    };
  };

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
