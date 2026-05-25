{ config, lib, ... }:
with lib;
let
  cfg = config.konrad.programs.ssh-egress;
in
{
  options.konrad.programs.ssh-egress = {
    enable = mkEnableOption "Enables ssh-egress configuration through home-manager";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = [ "config.d/*" ];
        settings = {

          "Host framework" = {
            HostName = "100.83.43.115";
          };

          "Host m4" = {
            HostName = "100.77.207.57";
          };

          "Host rpi4-1" = {
            HostName = "100.99.159.110";
          };

          "Host rpi4-2" = {
            HostName = "100.78.182.5";
          };

          "Host x1c6" = {
            HostName = "100.111.137.125";
          };

          "Host framework m4 rpi4-1 rpi4-2 x1c6" = {
            ForwardAgent = "yes";
            IdentitiesOnly = "yes";
            User = "${config.home.username}";
            IdentityFile = "${config.home.homeDirectory}/.ssh/personal";
          };

          "Host github.com gitlab.com bitbucket.org" = {
            IdentitiesOnly = "yes";
            User = "git";
            IdentityFile = "${config.home.homeDirectory}/.ssh/personal";
          };

          "Host *.cerebredev.com" = {
            IdentitiesOnly = "yes";
            IdentityFile = "${config.home.homeDirectory}/.ssh/cerebre";
          };

          "Host *" = {
            ForwardAgent = "no";
            ServerAliveInterval = 15;
            ServerAliveCountMax = 6;
            Compression = "yes";
            AddKeysToAgent = "yes";
            HashKnownHosts = "no";
            UserKnownHostsFile = "~/.ssh/known_hosts";
            ControlMaster = "auto";
            ControlPath = "/tmp/%r@%h:%p";
            ControlPersist = "1m";

            IgnoreUnknown = "UseKeychain";
            UseKeychain = "yes";
          };
        };
      };
    }
  ]);
}
