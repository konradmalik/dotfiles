{ pkgs, ... }:
{
  services.gnome-keyring = {
    enable = true;
    components = [ "ssh" ];
  };
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  home.packages = [ pkgs.seahorse ];
}
