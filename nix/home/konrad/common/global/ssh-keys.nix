{ lib, ... }:
{
  sshKeys = {
    personal =
      let
        githubKeys = builtins.readFile (builtins.fetchurl {
          url = "https://github.com/konradmalik.keys";
          sha256 = "sha256:0bajvxjz8d4x7r7z3jv18f3jakmycri0dksmcilxjnwsiqca7jyc";
        });
        gitlabKeys = builtins.readFile (builtins.fetchurl {
          url = "https://gitlab.com/konradmalik.keys";
          sha256 = "sha256:1l3r8zq420yw2pmgynihlplad983a1bypsm3zpzqxvf81ynfygag";
        });
        all = (lib.splitString "\n" githubKeys) ++ (lib.splitString "\n" gitlabKeys);
        keys = lib.filter (line: line != "" && !(lib.hasPrefix "#" line)) all;
      in
      keys;
  };
}
