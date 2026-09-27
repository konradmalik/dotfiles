{ pkgs, lib, ... }:
{
  home.packages =
    with pkgs;
    [
      curl
      dnsutils
      file
      inetutils
      lsof
      moreutils
      rsync
      tree
      unixtools.xxd
      wget

      croc
      ouch
      zip

      fd
      ripgrep
      ripgrep-all
      sad
      scooter

      dua
      entr
      hyperfine
      procs
      progress
      viddy

      age
      fq
      jc
      jo
      jq
      yq-go

      gh
      glab
    ]
    ++ (builtins.attrValues custom.scripts)
    ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
      psmisc
      trace-cmd
    ];
}
