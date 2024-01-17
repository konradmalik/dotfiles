{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin-docker;

  builderWithOverrides = pkgs.darwin.linux-builder.override
    {
      modules = [
        ({
          system = {
            name = "darwin-docker";
            stateVersion = "24.05";
          };

          virtualisation = {
            docker = {
              enable = true;
              autoPrune = {
                enable = true;
                flags = [ "--all" ];
                dates = "weekly";
              };
            };
          };
        })

        ({ virtualisation.darwin-builder.hostPort = 2376; })

        cfg.config
      ];
    };

  # create-builder uses TMPDIR to share files with the builder, notably certs.
  # macOS will clean up files in /tmp automatically that haven't been accessed in 3+ days.
  # If we let it use /tmp, leaving the computer asleep for 3 days makes the certs vanish.
  # So we'll use /run/org.nixos.darwin-docker instead and clean it up ourselves.
  script = pkgs.writeShellScript "darwin-docker-start" ''
    export TMPDIR=/run/org.nixos.darwin-docker USE_TMPDIR=1
    rm -rf $TMPDIR
    mkdir -p $TMPDIR
    trap "rm -rf $TMPDIR" EXIT
    ${lib.optionalString cfg.ephemeral ''
      rm -f ${cfg.workingDirectory}/${builderWithOverrides.nixosConfig.networking.hostName}.qcow2
    ''}
    ${builderWithOverrides}/bin/create-builder
  '';
in

{
  options.darwin-docker = {
    enable = mkEnableOption "enable Darwin Docker";

    config = mkOption {
      type = types.deferredModule;
      default = { };
      example = literalExpression ''
        ({ pkgs, ... }:

        {
          environment.systemPackages = [ pkgs.neovim ];
        })
      '';
      description = ''
        This option specifies extra NixOS configuration for the VM.
      '';
    };

    workingDirectory = mkOption {
      type = types.str;
      default = "/var/lib/darwin-docker";
      description = lib.mdDoc ''
        The working directory of the Darwin docker daemon process.
      '';
    };

    ephemeral = mkEnableOption (lib.mdDoc ''
      wipe the VM's filesystem on every restart.

      This is disabled by default as maintaining the VM's filesystem keeps all docker images
      etc. from downloading each time the VM is started.
    '');
  };

  config = mkIf cfg.enable {
    system.activationScripts.preActivation.text = ''
      mkdir -p ${cfg.workingDirectory}
    '';

    launchd.daemons.darwin-docker = {
      serviceConfig = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          "/bin/wait4path /nix/store &amp;&amp; exec ${script}"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        WorkingDirectory = cfg.workingDirectory;
      };
    };

    environment = {
      variables = {
        DOCKER_HOST = "ssh://darwin-docker:2376";
      };

      # TODO the VM starts, but I cannot login, due to keys having bad permissions
      # this as root connects ok: ssh -i /var/lib/darwin-docker/keys/builder_ed25519 -- builder@darwin-docker
      # I need to:
      # - make user builder valid as docker user (docker group)
      # - make it so that I can "just" connect without root
      etc."ssh/ssh_config.d/100-darwin-docker.conf".text = ''
        Host darwin-docker
          HostName localhost
          HostKeyAlias darwin-docker
          StrictHostKeyChecking no
          IdentityFile ${cfg.workingDirectory}/keys/builder_ed25519
          Port 2376
      '';
    };
  };
}
