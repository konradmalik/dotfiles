{ config, pkgs, lib, osConfig, ... }:
with lib;
let cfg = config.konrad.programs.ssh-egress;
in {
  options.konrad.programs.ssh-egress = {
    enable = mkEnableOption "Enables ssh-egress configuration through home-manager";
    enableSecret = mkOption {
      type = types.bool;
      default = true;
      description = "whether to enable secret ssh config.d (requires sops-nix and age key)";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # TODO:
      # 1. move this to git.nix (enable only for trusted? or always?)
      # 2. split into cerebre and personal https://markentier.tech/posts/2021/02/github-with-multiple-profiles-gpg-ssh-keys/
      #    also: https://rycee.gitlab.io/home-manager/options.html#opt-programs.git.includes
      # 3. cleverly choose ssh key (something with gpg.ssh.defaultKeyCommand="ssh-add -L")
      programs.git.signing = {
        key = "${config.home.homeDirectory}/.ssh/personal";
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
        '' + optionalString pkgs.stdenvNoCC.isDarwin
          ''
            UseKeychain yes
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
          vaio = hm.dag.entryAfter [ "tailscale" ] {
            hostname = "100.67.103.124";
          };
          xps12 = hm.dag.entryAfter [ "tailscale" ] {
            hostname = "100.115.164.124";
          };
          rpi4-1 = hm.dag.entryAfter [ "tailscale" ] {
            hostname = "100.99.159.110";
          };
          rpi4-2 = hm.dag.entryAfter [ "tailscale" ] {
            hostname = "100.78.182.5";
          };
          m3800 = hm.dag.entryAfter [ "tailscale" ] {
            hostname = "100.108.89.62";
          };
          mbp13 = hm.dag.entryAfter [ "tailscale" ] {
            hostname = "100.70.57.115";
          };
        } // lib.optionalAttrs (pkgs.stdenvNoCC.isDarwin) {
          darwin-docker = {
            host = "darwin-docker";
            hostname = "127.0.0.1";
            port = 2376;
            user = "root";
            identityFile = "${config.home.homeDirectory}/.ssh/personal";
            extraOptions = {
              StrictHostKeyChecking = "no";
            };
          };
          devnix = {
            host = "devnix";
            hostname = "127.0.0.1";
            port = 2222;
            user = "konrad";
            identityFile = "${config.home.homeDirectory}/.ssh/personal";
            extraOptions = {
              StrictHostKeyChecking = "no";
            };
          };
        };
      };
    }
    (mkIf cfg.enableSecret {
      sops.secrets."ssh_configd/cerebre" = {
        path = "${config.home.homeDirectory}/.ssh/config.d/cerebre";
      };
    })
  ]);
}
