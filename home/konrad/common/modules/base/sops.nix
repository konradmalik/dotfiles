{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  # shared sops config
  sops = {
    defaultSopsFile = ./../../secrets.yaml;
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };

  home.sessionVariables =
    # I want to have it in the same place as on linux
    lib.optionalAttrs (pkgs.stdenvNoCC.isDarwin) {
      SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
    };
}
