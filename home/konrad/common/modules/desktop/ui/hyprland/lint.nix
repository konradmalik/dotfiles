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
    dir=''${1:-}
    if [ ! -d "$dir" ]; then
      echo "usage: hyprland-lua-lint <dir containing the lua>" >&2
      exit 2
    fi

    mapfile -t files < <(find "$dir" -name '*.lua' | sort)

    # a silent pass and a pass over nothing at all look exactly alike
    if [ ''${#files[@]} -eq 0 ]; then
      echo "hyprland-lua-lint: no lua in $dir" >&2
      exit 2
    fi
    echo "hyprland-lua-lint: checking ''${#files[@]} lua files in $dir"

    # luacheck searches upward from the working directory for its config,
    # not from the files, so point it at the one next to them
    ${lib.getExe luajitPackages.luacheck} \
      --codes \
      --no-cache \
      --config "$dir/.luacheckrc" \
      "''${files[@]}"

    # unlike luacheck this resolves `hl` against hyprland's stubs, so a
    # misspelled dispatcher is an error rather than a field of an unknown
    # global. --check exits 0 on hints, so Warning is the level that fails.
    # metapath and logpath must be writable, and belong in neither the
    # checkout nor the store.
    scratch=$(mktemp -d)
    trap 'rm -rf "$scratch"' EXIT
    ${lib.getExe lua-language-server} \
      --check="$dir" \
      --checklevel=Warning \
      --configpath=${luarc} \
      --metapath="$scratch" \
      --logpath="$scratch"
  '';
}
