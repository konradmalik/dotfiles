{ pkgs, lib, ... }:
{
  home.packages =
    with pkgs;
    [
      croc
      ouch

      ripgrep-all
      sad
      scooter

      entr
      hyperfine
      viddy

      age
      fq
      jc
      jo
      yq-go

      gh
      glab
    ]
    ++ (builtins.attrValues custom.scripts)
    ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
      trace-cmd
    ];
}
