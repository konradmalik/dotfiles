{ pkgs, inputs, ... }:
let
  inherit (pkgs.stdenvNoCC.hostPlatform) system;
in
{
  home.packages = [ inputs.llm-agents.packages.${system}.opencode ];

  xdg.configFile."opencode/config.json".source = ./config.json;
}
