{
  lib,
  callPackage,
  quickshell,
  symlinkJoin,
  writeShellScriptBin,
}:
let
  qt = callPackage ./qt.nix { };

  wrap =
    name:
    writeShellScriptBin name ''
      export QML_IMPORT_PATH="${qt.qtdeclarative}/${qt.qtbase.qtQmlPrefix}:${quickshell}/${qt.qtbase.qtQmlPrefix}''${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
      exec ${lib.getExe' qt.qtdeclarative name} -E "$@"
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
      (writeShellScriptBin "qmlformat" ''exec ${lib.getExe' qt.qtdeclarative "qmlformat"} "$@"'')
    ];
}
