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
        extraConfig = ''
          IgnoreUnknown UseKeychain
          UseKeychain yes
        '';
        includes = [ "config.d/*" ];
        matchBlocks = {
          "*" = {
            forwardAgent = false;
            addKeysToAgent = "yes";
            compression = true;
            serverAliveInterval = 15;
            serverAliveCountMax = 6;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "auto";
            controlPath = "/tmp/%r@%h:%p";
            controlPersist = "1m";
          };
          git = {
            host = "github.com gitlab.com bitbucket.org";
            user = "git";
            identityFile = "${config.home.homeDirectory}/.ssh/personal";
            identitiesOnly = true;
          };
          tailscale = {
            host = "framework m4 rpi4-1 rpi4-2 x1c6";
            user = "${config.home.username}";
            forwardAgent = true;
            identityFile = "${config.home.homeDirectory}/.ssh/personal";
            identitiesOnly = true;
          };
          framework = hm.dag.entryAfter [ "tailscale" ] { hostname = "100.83.43.115"; };
          m4 = hm.dag.entryAfter [ "tailscale" ] { hostname = "100.77.207.57"; };
          rpi4-1 = hm.dag.entryAfter [ "tailscale" ] { hostname = "100.99.159.110"; };
          rpi4-2 = hm.dag.entryAfter [ "tailscale" ] { hostname = "100.78.182.5"; };
          x1c6 = hm.dag.entryAfter [ "tailscale" ] { hostname = "100.111.137.125"; };
          work = {
            host = "*.cerebredev.com";
            identityFile = "${config.home.homeDirectory}/.ssh/cerebre";
            identitiesOnly = true;
          };
        };
      };
    }
  ]);
}
