{
  findutils,
  lib,
  qt6,
  quickshell,
  runCommandLocal,
  writeShellApplication,
}:
let
  root = ./.;

  # Which warnings are silenced lives in .qmllint.ini next to this file, so
  # that qmlls -- which runs qmllint internally and looks for the same file --
  # agrees with this linter instead of flagging in the editor what CI ignores.

  command = writeShellApplication {
    name = "quickshell-lint";
    runtimeInputs = [ findutils ];
    text = ''
      # The directory holding qs/. Given one, use it; otherwise look for it
      # from the top of the checkout, so this works from anywhere inside it --
      # including the root, where qs/ is far below rather than above.
      dir="''${1:-}"
      if [ -z "$dir" ]; then
        top=$PWD
        while [ "$top" != "/" ] && [ ! -d "$top/.git" ]; do
          top=$(dirname "$top")
        done
        [ -d "$top/.git" ] || top=$PWD

        found=$(find "$top" -type f -path '*/qs/shell.qml' -not -path '*/.git/*' -print -quit 2>/dev/null || true)
        dir=''${found%/qs/shell.qml}
      fi

      if [ ! -e "$dir/qs/shell.qml" ]; then
        echo "quickshell-lint: no qs/shell.qml found under $PWD or its checkout" >&2
        exit 2
      fi

      mapfile -t files < <(find "$dir/qs" -name '*.qml' | sort)

      # Saying what was covered, because a silent pass and a pass over nothing
      # at all look exactly alike.
      if [ ''${#files[@]} -eq 0 ]; then
        echo "quickshell-lint: no qml under $dir/qs" >&2
        exit 2
      fi
      echo "quickshell-lint: checking ''${#files[@]} qml files in $dir/qs"

      # qmllint reports warnings and still exits 0,
      # so '--max-warnings 0' is what makes it fail properly
      ${lib.getExe' qt6.qtdeclarative "qmllint"} \
        -I ${qt6.qtdeclarative}/${qt6.qtbase.qtQmlPrefix} \
        -I ${quickshell}/${qt6.qtbase.qtQmlPrefix} \
        -I "$dir" \
        --max-warnings 0 \
        "''${files[@]}"
    '';
  };
in
command
// {
  check = runCommandLocal "quickshell-qmllint" { } ''
    ${lib.getExe command} ${root}
    touch $out
  '';
}
