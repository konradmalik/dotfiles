{ pkgs, inputs, ... }:
let
  inherit (pkgs.stdenvNoCC.hostPlatform) system;
in
{
  home.packages = [ inputs.llm-agents.packages.${system}.claude-code ];

  home.file.".claude/settings.json".source = ./settings.json;

  programs.git.ignores = [ ".claude" ];
}
