# qml tooling for the quickshell config in this directory: the language server
# the editor talks to, and the linter behind it.
# put on PATH by the devShell, see flake.nix
{
  lib,
  qt6,
  quickshell,
  symlinkJoin,
  writeShellScriptBin,
}:
let
  # nixpkgs keeps every qt module in its own store path, so these find no qml
  # modules on their own -- not even QtQuick. '-E' makes them read
  # QML_IMPORT_PATH, which is pointed at qtdeclarative and quickshell here, and
  # at the checkout itself by the devShell, so that the shell's own `qs.*`
  # modules resolve too.
  wrap =
    name:
    writeShellScriptBin name ''
      export QML_IMPORT_PATH="${qt6.qtdeclarative}/${qt6.qtbase.qtQmlPrefix}:${quickshell}/${qt6.qtbase.qtQmlPrefix}''${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
      exec ${lib.getExe' qt6.qtdeclarative name} -E "$@"
    '';
in
symlinkJoin {
  name = "quickshell-qml-tools";
  paths = map wrap [
    "qmlls"
    "qmllint"
  ];
}
