# qml-language-server for the quickshell config in this directory.
# put on PATH by the devShell, see flake.nix
{
  lib,
  qt6,
  quickshell,
  writeShellScriptBin,
}:
# nixpkgs keeps every qt module in its own store path, so qmlls finds no qml
# modules on its own -- not even QtQuick. '-E' makes it read QML_IMPORT_PATH,
# which is pointed at qtdeclarative and quickshell here, and at the checkout
# itself by the devShell, so that the shell's own `qs.*` modules resolve too.
writeShellScriptBin "qmlls" ''
  export QML_IMPORT_PATH="${qt6.qtdeclarative}/${qt6.qtbase.qtQmlPrefix}:${quickshell}/${qt6.qtbase.qtQmlPrefix}''${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
  exec ${lib.getExe' qt6.qtdeclarative "qmlls"} -E "$@"
''
