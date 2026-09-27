{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.konrad.network.wireless;

  secretNetworks = filterAttrs (_: net: net.passphraseSecret != null) cfg.networks;

  envVar = name: "PSK_" + toUpper (replaceStrings [ "-" ] [ "_" ] name);

  profile = name: net: {
    connection = {
      id = name;
      type = "wifi";
    };
    wifi = {
      inherit (net) ssid;
      mode = "infrastructure";
    };
    wifi-security = {
      key-mgmt = net.keyMgmt;
      psk = if net.passphraseSecret != null then "\${${envVar name}}" else net.passphrase;
    };
    ipv4.method = "auto";
    # these lans hand out no global v6, and "disabled" would drop link-local too
    ipv6.method = "link-local";
  };
in
{
  options.konrad.network.wireless = {
    enable = mkEnableOption "Enables custom network config";

    networks = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              ssid = mkOption {
                type = types.str;
                default = name;
                description = "The ssid to look for, when it differs from the profile name.";
              };

              keyMgmt = mkOption {
                type = types.str;
                default = "wpa-psk";
                example = "sae";
                description = "NetworkManager's `wifi-security.key-mgmt`. WPA3-only networks want `sae`.";
              };

              passphrase = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = ''
                  Passphrase in plain text, ends up world readable in the nix store.
                  Mutually exclusive with passphraseSecret.
                '';
              };

              passphraseSecret = mkOption {
                type = types.nullOr types.str;
                default = null;
                example = "wifi/home";
                description = ''
                  Name of a sops secret holding the passphrase. The secret is
                  declared for you and substituted into the profile at runtime, so
                  it never reaches the nix store.
                  Mutually exclusive with passphrase.
                '';
              };
            };
          }
        )
      );
      default = { };
      example = literalExpression ''
        {
          home = {
            ssid = "some ssid";
            passphraseSecret = "wifi/home";
          };
          cafe.passphrase = "freecoffee";
        }
      '';
      description = ''
        Known wifi networks, keyed by profile name.

        These are regenerated under /run on every boot, so removing one here
        removes it from the machine. Networks joined by hand live in /etc
        instead and are left alone, so the two coexist.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions =
      mapAttrsToList (name: net: {
        assertion = (net.passphrase == null) != (net.passphraseSecret == null);
        message = ''konrad.network.wireless.networks."${name}": set exactly one of passphrase and passphraseSecret'';
      }) cfg.networks
      ++ mapAttrsToList (name: _: {
        # the name is both a keyfile name and, uppercased, a shell identifier;
        # excluding "_" keeps the "-" -> "_" rewrite from colliding
        assertion = builtins.match "[A-Za-z0-9-]+" name != null;
        message = ''konrad.network.wireless.networks."${name}": name must match [A-Za-z0-9-]+'';
      }) cfg.networks;

    environment.systemPackages = [ pkgs.wifitui ];

    services.resolved.enable = !config.services.blocky.enable;

    sops = mkIf (secretNetworks != { }) {
      secrets = genAttrs (mapAttrsToList (_: net: net.passphraseSecret) secretNetworks) (_: { });

      templates."networkmanager.env" = {
        content = concatStrings (
          mapAttrsToList (
            name: net: "${envVar name}=${config.sops.placeholder.${net.passphraseSecret}}\n"
          ) secretNetworks
        );
        restartUnits = [ "NetworkManager-ensure-profiles.service" ];
      };
    };

    networking.networkmanager = {
      enable = true;

      ensureProfiles = {
        environmentFiles = optional (secretNetworks != { }) config.sops.templates."networkmanager.env".path;
        profiles = mapAttrs profile cfg.networks;
      };
    };
  };
}
