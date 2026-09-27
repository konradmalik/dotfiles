{
  lib,
  qt6,
  quickshell,
  symlinkJoin,
  writeShellScriptBin,
}:
let
  wrap =
    name:
    writeShellScriptBin name ''
      export QML_IMPORT_PATH="${qt6.qtdeclarative}/${qt6.qtbase.qtQmlPrefix}:${quickshell}/${qt6.qtbase.qtQmlPrefix}''${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
      exec ${lib.getExe' qt6.qtdeclarative name} -E "$@"
    '';
in
symlinkJoin {
  name = "quickshell-qml-tools";
  paths =
    map wrap [
      "qmlls"
      "qmllint"
    ]
    ++ [
      (writeShellScriptBin "qmlformat" ''exec ${lib.getExe' qt6.qtdeclarative "qmlformat"} "$@"'')
    ];
}
