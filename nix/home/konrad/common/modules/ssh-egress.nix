{ config, pkgs, lib, osConfig, ... }:
with lib;
let cfg = config.konrad.programs.ssh-egress;
in {
  options.konrad.programs.ssh-egress = {
    enable = mkEnableOption "Enables ssh-egress configuration through home-manager";
  };

  config = mkIf cfg.enable
    {
      programs.git.signing = {
        key = "~/.ssh/personal";
        signByDefault = true;
      };

      programs.ssh = {
        enable = true;
        compression = true;
        controlMaster = "auto";
        controlPath = "/tmp/%r@%h:%p";
        controlPersist = "1m";
        serverAliveCountMax = 6;
        serverAliveInterval = 15;
        extraConfig = ''
          AddKeysToAgent yes
        '';

        includes = [ "config.d/*" ];
        matchBlocks = {
          git = {
            host = "github.com gitlab.com bitbucket.org";
            user = "git";
            identityFile = "${config.home.homeDirectory}/.ssh/personal";
          };
          tailscale = {
            host = "vaio xps12 rpi4-1 rpi4-2 m3800 mbp13";
            user = "${config.home.username}";
            forwardAgent = true;
            identityFile = "${config.home.homeDirectory}/.ssh/personal";
          };
          vaio = lib.hm.dag.entryAfter [ "tailscale" ] {
            hostname = "100.67.103.124";
          };
          xps12 = lib.hm.dag.entryAfter [ "tailscale" ] {
            hostname = "100.115.164.124";
          };
          rpi4-1 = lib.hm.dag.entryAfter [ "tailscale" ] {
            hostname = "100.99.159.110";
          };
          rpi4-2 = lib.hm.dag.entryAfter [ "tailscale" ] {
            hostname = "100.78.182.5";
          };
          m3800 = lib.hm.dag.entryAfter [ "tailscale" ] {
            hostname = "100.108.89.62";
          };
          mbp13 = lib.hm.dag.entryAfter [ "tailscale" ] {
            hostname = "100.70.57.115";
          };
        };
      };

      # TODO ssh_configd from osConfig.sops.secrets when
      # https://github.com/Mic92/sops-nix/pull/168
      # gets merged
    };
}
