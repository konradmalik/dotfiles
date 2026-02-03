{ pkgs, ... }:
{
  home.packages = [ pkgs.llm-agents.opencode ];

  xdg.configFile."opencode/config.json".source = ./config.json;
}
