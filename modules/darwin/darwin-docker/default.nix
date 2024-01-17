{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix.darwin-docker;

  package = import ./package
    {
      # TODO
      guestPkgs = pkgs;
    };

  builderWithOverrides = package.override {
    modules = [ cfg.config ];
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
  options.nix.darwin-docker = {
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
      wipe the builder's filesystem on every restart.

      This is disabled by default as maintaining the builder's filesystem keeps all docker images
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

    environment.etc."ssh/ssh_config.d/100-linux-builder.conf".text = ''
      Host darwin-docker
        Port 2376
        IdentitiesOnly yes
        User root
        HostName 127.0.0.1
        IdentityFile /Users/konrad/.ssh/personal
        StrictHostKeyChecking no

       Host linux-builder
         Hostname localhost
         HostKeyAlias linux-builder
         Port 31022
    '';
  };

  sessionVariables = {
    DOCKER_HOST = "ssh://darwin-docker:2376";
  };
}
