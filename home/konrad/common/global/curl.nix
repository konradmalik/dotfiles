{ pkgs, ... }:
{
  xdg.configFile.".curlrc".text = ''
    --include
    --write-out "Stats:\ndnslookup: %{time_namelookup}\nconnect: %{time_connect}\nappconnect: %{time_appconnect}\npretransfer: %{time_pretransfer}\nstarttransfer: %{time_starttransfer}\ntotal: %{time_total}\nsize: %{size_download}\n"
  '';
  home.packages = [ pkgs.curl ];
}
