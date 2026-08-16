{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.konrad.network.wireless;

  provisionNetwork =
    ssid: net:
    if net.passphraseFile != null then
      "  iwdProvisionFile ${escapeShellArg ssid} ${escapeShellArg (toString net.passphraseFile)}\n"
    else
      "  iwdProvision ${escapeShellArg ssid} ${escapeShellArg net.passphrase}\n";

  provisionScript =
    # bash
    ''
      (
      export LC_ALL=C

      stamps=/var/lib/iwd-networks
      install -d -m 0700 /var/lib/iwd "$stamps"

      iwdProvision() {
        local ssid="$1" passphrase="$2" name desired hash verbatim='^[A-Za-z0-9_ -]+$'

        # iwd takes the ssid from the file name, and only alphanumerics, spaces,
        # dashes and underscores may appear there verbatim, anything else means the
        # whole ssid is hex encoded, see storage_get_network_file_path in iwd
        if [[ "$ssid" =~ $verbatim ]]; then
          name="$ssid.psk"
        else
          name="=$(printf '%s' "$ssid" | od -An -v -tx1 | tr -d ' \n').psk"
        fi

        desired=$(printf '[Security]\nPassphrase=%s' "$passphrase")
        hash=$(printf '%s' "$desired" | sha256sum | cut -d ' ' -f1)

        # rewrite only when what is declared here changed, so that whatever iwd itself
        # stored in the meantime (PreSharedKey, cached SAE points) is kept
        if [ "$hash" = "$(cat "$stamps/$name" 2>/dev/null)" ]; then
          return 0
        fi

        printf '%s\n' "$desired" >"/var/lib/iwd/$name"
        chmod 0600 "/var/lib/iwd/$name"
        printf '%s\n' "$hash" >"$stamps/$name"
      }

      iwdProvisionFile() {
        if [ ! -r "$2" ]; then
          echo "iwd-networks: $2 is not readable, skipping $1" >&2
          return 0
        fi

        iwdProvision "$1" "$(cat "$2")"
      }

      ${concatStrings (mapAttrsToList provisionNetwork cfg.networks)}
      )
    '';
in
{
  options.konrad.network.wireless = {
    enable = mkEnableOption "Enables custom network config";

    networks = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            passphrase = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = ''
                Passphrase in plain text, ends up world readable in the nix store.
                Mutually exclusive with passphraseFile.
              '';
            };

            passphraseFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              example = literalExpression ''config.sops.secrets."wifi/home".path'';
              description = ''
                Path to a file holding the passphrase, read at activation time.
                Mutually exclusive with passphrase.
              '';
            };
          };
        }
      );
      default = { };
      example = literalExpression ''
        {
          "home".passphraseFile = config.sops.secrets."wifi/home".path;
          "some cafe".passphrase = "freecoffee";
        }
      '';
      description = ''
        Known wifi networks, keyed by ssid, provisioned into /var/lib/iwd.

        A network is (re)written only when the passphrase declared here changes, so
        iwd stays free to update the files at runtime (e.g. when the passphrase is
        changed through iwctl) and such changes survive until the declaration itself
        changes. Removing a network here does not remove it from /var/lib/iwd.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = mapAttrsToList (ssid: net: {
      assertion = (net.passphrase == null) != (net.passphraseFile == null);
      message = ''konrad.network.wireless.networks."${ssid}": set exactly one of passphrase and passphraseFile'';
    }) cfg.networks;

    environment.systemPackages = with pkgs; [
      impala
    ];

    services.resolved.enable = !config.services.blocky.enable;
    networking = {
      wireless.iwd = {
        enable = true;
        settings = {
          Settings.AutoConnect = true;

          Network = {
            EnableIPv6 = false;
          };
        };
      };
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };

    # runs on every activation and on boot before iwd is started, iwd itself watches
    # its storage dir so it picks the files up without a restart
    system.activationScripts.iwd-networks = mkIf (cfg.networks != { }) {
      deps = optional (config.sops.secrets != { } && !config.sops.useSystemdActivation) "setupSecrets";
      text = provisionScript;
    };
  };
}
