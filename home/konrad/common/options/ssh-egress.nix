{ config, lib, ... }:
with lib;
let
  cfg = config.konrad.programs.ssh-egress;
  # hardware-backed keys are offered first, the on-disk one stays as a fallback
  personalKeys = cfg.hardwareKeys ++ [ "${config.home.homeDirectory}/.ssh/personal" ];
in
{
  options.konrad.programs.ssh-egress = {
    enable = mkEnableOption "Enables ssh-egress configuration through home-manager";

    hardwareKeys = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "~/.ssh/id_ecdsa.pub" ];
      description = ''
        Keys backed by this machine's security chip (tpm on linux, secure enclave on darwin).
        Tried in order, before the on-disk fallback key.
        On linux these are the public halves only, the private ones never leave the agent.
      '';
    };
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
            IdentityFile = personalKeys;
          };

          "Host github.com gitlab.com bitbucket.org" = {
            IdentitiesOnly = "yes";
            User = "git";
            IdentityFile = personalKeys;
          };

          "Host *.cerebredev.com" = {
            IdentitiesOnly = "yes";
            IdentityFile = "${config.home.homeDirectory}/.ssh/cerebre";
          };

          # must be named "*" so home-manager emits it last;
          # ssh takes the first obtained value for each keyword
          "*" = {
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
