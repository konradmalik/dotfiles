{ config, lib, ... }:
with lib;
let
  cfg = config.sshKeys;
  fetchKeys = s: builtins.readFile (builtins.fetchurl s);
  splitKeys = keys: splitString "\n" keys;
  filterLines = lines: filter (line: line != "" && !(hasPrefix "#" line)) lines;
in
{
  options.sshKeys = {
    personal = {
      remotes = mkOption {
        default = [ ];
        description = "urls and their sha256 that will be passed to fetchurl function";
        type = types.listOf (types.submodule {
          options = {
            url = mkOption {
              type = types.str;
              example = "https://github.com/konradmalik.keys";
            };
            sha256 = mkOption {
              type = types.str;
              example = "sha256:0i8s5nc48dpf1rvjnk22ny03ckvyk4mpydgd48g2wz687v8wip05";
            };
          };
        });
      };
      extraKeys = mkOption {
        type = types.listOf types.str;
        example = ''[ "ssh-rsa abcd" ]'';
        default = [ ];
        description = "extra keys to be added";
      };
      keys = mkOption {
        type = types.listOf types.str;
        readOnly = true;
        description = "all keys";
      };
    };
    work = {
      keys = mkOption {
        type = types.attrsOf types.str;
        example = ''{ company="ssh-rsa abcd" }'';
        default = { };
        description = "company - key mapping to be added";
      };
    };
  };

  config =
    let
      contents = builtins.map fetchKeys cfg.personal.remotes;
      splits = flatten (builtins.map splitKeys contents);
      filtered = filterLines splits;
    in
    {
      sshKeys.personal.keys = filtered ++ cfg.personal.extraKeys;
    };
}
