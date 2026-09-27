# lua-language-server config for the hyprland config lua files in this directory.
# linked into place as .luarc.json by the devShell, see flake.nix
{
  formats,
  hyprland,
  lib,
  stdenvNoCC,
}:
let
  # the stubs give completion and types for `hl`, and declare it as a global
  # themselves. they only exist on linux though, so elsewhere we settle for
  # silencing the undefined-global diagnostic.
  hasStubs = stdenvNoCC.hostPlatform.isLinux;
in
(formats.json { }).generate "hyprland-luarc.json" (
  {
    "$schema" = "https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json";
    "runtime.version" = "Lua 5.4";
    "workspace.checkThirdParty" = false;
  }
  // lib.optionalAttrs hasStubs { "workspace.library" = [ "${hyprland}/share/hypr/stubs" ]; }
  // lib.optionalAttrs (!hasStubs) { "diagnostics.globals" = [ "hl" ]; }
)
