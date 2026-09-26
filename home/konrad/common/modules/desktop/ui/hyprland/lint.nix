{
  callPackage,
  findutils,
  lib,
  lua-language-server,
  luajitPackages,
  writeShellApplication,
}:
let
  # the same file the devShell links in as .luarc.json
  luarc = callPackage ./luarc.nix { };
in
writeShellApplication {
  name = "hyprland-lua-lint";
  runtimeInputs = [ findutils ];
  text = ''
    # The directory holding the lua. Given one, use it; otherwise look for it
    # from the top of the checkout, so this works from anywhere inside it.
    dir="''${1:-}"
    if [ -z "$dir" ]; then
      top=$PWD
      while [ "$top" != "/" ] && [ ! -d "$top/.git" ]; do
        top=$(dirname "$top")
      done
      [ -d "$top/.git" ] || top=$PWD

      found=$(find "$top" -type f -path '*/hyprland/bindings.lua' -not -path '*/.git/*' -print -quit 2>/dev/null || true)
      dir=''${found%/bindings.lua}
    fi

    if [ ! -e "$dir/bindings.lua" ]; then
      echo "hyprland-lua-lint: no hyprland/bindings.lua found under $PWD or its checkout" >&2
      exit 2
    fi

    mapfile -t files < <(find "$dir" -maxdepth 1 -name '*.lua' | sort)

    # Saying what was covered, because a silent pass and a pass over nothing
    # at all look exactly alike.
    if [ ''${#files[@]} -eq 0 ]; then
      echo "hyprland-lua-lint: no lua in $dir" >&2
      exit 2
    fi
    echo "hyprland-lua-lint: checking ''${#files[@]} lua files in $dir"

    # luacheck only searches upward from the working directory for its
    # config, so point it at the one next to the files instead.
    ${lib.getExe luajitPackages.luacheck} \
      --codes \
      --no-cache \
      --config "$dir/.luacheckrc" \
      "''${files[@]}"

    # both of these must be writable, and neither belongs in the checkout
    scratch=$(mktemp -d)
    trap 'rm -rf "$scratch"' EXIT

    # unlike luacheck this resolves `hl` against hyprland's stubs, so a
    # misspelled dispatcher is an error rather than a field of an unknown
    # global. --check exits 0 on hints, so Warning is the level that fails.
    ${lib.getExe lua-language-server} \
      --check="$dir" \
      --checklevel=Warning \
      --configpath=${luarc} \
      --metapath="$scratch" \
      --logpath="$scratch"
  '';
}
