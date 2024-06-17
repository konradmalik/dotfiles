{ pkgs, ... }:
{
  services.gnome-keyring = {
    enable = true;
    components = [ "ssh" ];
  };
  home.sessionVariables.SSH_AUTH_SOCK = "/run/user/$UID/keyring/ssh";
  home.packages = [ pkgs.gnome.seahorse ];
}
