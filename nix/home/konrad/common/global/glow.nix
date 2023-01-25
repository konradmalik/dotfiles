{ pkgs, lib, ... }:
{
  xdg.configFile."glow/glow.yml".text = ''
    # style name or JSON path (default "auto")
    style: "dark"
    # show local files only; no network (TUI-mode only)
    local: true
    # mouse support (TUI-mode only)
    mouse: false
    # use pager to display markdown
    pager: true
    # word-wrap at width
    width: 80
  '';
  home.packages = [ pkgs.glow ];
}
