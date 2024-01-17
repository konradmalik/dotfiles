{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin-docker;

  # TODO dont use stable in general
  # we build on top of linux-builder
  builderWithOverrides = pkgs.stable.darwin.linux-builder.override
    {
      modules = [
        ({
          # to not conflict with docker-builder
          virtualisation.darwin-builder.hostPort = 31023;
        })

        ({
          system = {
            name = "darwin-docker";
            stateVersion = "24.05";
          };

          virtualisation = {
            docker = {
              enable = true;
              daemon.settings = {
                hosts = [ "tcp://0.0.0.0:2375" ];
              };
            };
            forwardPorts = [
              { from = "host"; guest.port = 2375; host.port = 2375; }
            ];
          };
          networking.firewall.allowedTCPPorts = [ 2375 ];
        })

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
      description = ''
        The working directory of the Darwin docker daemon process.
      '';
    };

    ephemeral = mkEnableOption ''
      wipe the VM's filesystem on every restart.

      This is disabled by default as maintaining the VM's filesystem keeps all docker images
      etc. from downloading each time the VM is started.
    '';
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
        DOCKER_HOST = "tcp://127.0.0.1:2375";
      };
    };
  };
}
