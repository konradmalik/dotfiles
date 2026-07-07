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
      tree
      unixtools.xxd
      wget

      # FIXME unstable has hash mismatch
      stable.croc
      ouch
      zip

      fd
      fpp
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
    ++ lib.optionals stdenvNoCC.isLinux [
      psmisc
      trace-cmd
    ]
    ++ lib.optionals stdenvNoCC.isDarwin [ colima ];
}
