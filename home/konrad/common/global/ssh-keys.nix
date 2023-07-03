{ lib, ... }:
{
  sshKeys.personal.remotes = [
    {
      url = "https://github.com/konradmalik.keys";
      sha256 = "sha256:0bajvxjz8d4x7r7z3jv18f3jakmycri0dksmcilxjnwsiqca7jyc";
    }
    {
      url = "https://gitlab.com/konradmalik.keys";
      sha256 = "sha256:1l3r8zq420yw2pmgynihlplad983a1bypsm3zpzqxvf81ynfygag";
    }
  ];
}
