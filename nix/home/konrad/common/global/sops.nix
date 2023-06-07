{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.sessionVariables =
    # I want to have it in the same place as on linux
    lib.optionalAttrs (pkgs.stdenvNoCC.isDarwin) {
      SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
    };
}
