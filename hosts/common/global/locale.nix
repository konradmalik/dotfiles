{ lib, ... }:
{
  # Set your time zone.
  time.timeZone = lib.mkDefault "Europe/Warsaw";
  # Select internationalisation properties.
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = lib.mkDefault "pl_PL.UTF-8";
    };
    supportedLocales = lib.mkDefault [
      "en_US.UTF-8/UTF-8"
      "pl_PL.UTF-8/UTF-8"
    ];
  };
}
