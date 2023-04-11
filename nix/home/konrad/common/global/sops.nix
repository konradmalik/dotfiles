{ config, ... }:
{
  # I want to have it in the same place as on linux
  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
  };
}
