{ lib, pkgs, ... }:
let
  quickshellDir = "home/modules/desktop/quickshell";
  # the same package the devShell carries
  qmlTools = pkgs.callPackage ./${quickshellDir}/qml-tools.nix { };
in
{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    stylua.enable = true;
    prettier = {
      enable = true;
      includes = [
        "*.json"
        "*.md"
        "*.yaml"
        "*.yml"
      ];
    };
    shfmt = {
      enable = true;
      useEditorConfig = true;
      includes = [ "*.sh" ];
    };
    shellcheck = {
      enable = true;
      includes = [ "*.sh" ];
    };
  };

  settings.formatter = lib.mkIf pkgs.stdenvNoCC.hostPlatform.isLinux {
    qmlformat = {
      command = lib.getExe' qmlTools "qmlformat";
      options = [ "--inplace" ];
      includes = [ "${quickshellDir}/**/*.qml" ];
    };
  };
}
