{
  findutils,
  lib,
  callPackage,
  quickshell,
  writeShellApplication,
}:
let
  qt = callPackage ./qt.nix { };
in
writeShellApplication {
  name = "quickshell-lint";
  runtimeInputs = [ findutils ];
  text = ''
    dir=''${1:-}
    if [ ! -d "$dir/qs" ]; then
      echo "usage: quickshell-lint <dir containing qs/>" >&2
      exit 2
    fi

    mapfile -t files < <(find "$dir/qs" -name '*.qml' | sort)

    # a silent pass and a pass over nothing at all look exactly alike
    if [ ''${#files[@]} -eq 0 ]; then
      echo "quickshell-lint: no qml under $dir/qs" >&2
      exit 2
    fi
    echo "quickshell-lint: checking ''${#files[@]} qml files in $dir/qs"

    # qmllint reports warnings and still exits 0,
    # so '--max-warnings 0' is what makes it fail properly
    ${lib.getExe' qt.qtdeclarative "qmllint"} \
      -I ${qt.qtdeclarative}/${qt.qtbase.qtQmlPrefix} \
      -I ${quickshell}/${qt.qtbase.qtQmlPrefix} \
      -I "$dir" \
      --max-warnings 0 \
      "''${files[@]}"
  '';
}
