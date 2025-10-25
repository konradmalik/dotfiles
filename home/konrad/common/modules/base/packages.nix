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
      ouch
      progress
      tree
      unixtools.xxd
      wget
      zip

      fd
      fpp
      ripgrep
      ripgrep-all
      sad
      scooter

      entr
      hyperfine
      noti
      spacer
      viddy

      age
      fq
      dsq
      jc
      jo
      jq
      yq-go

      du-dust
      duf
      procs

      croc
      gh
      glab

      realize-symlink
      terminal-testdrive
      uniq-exts
    ]
    ++ lib.optionals stdenvNoCC.isLinux [
      psmisc
      trace-cmd
    ]
    ++ lib.optionals stdenvNoCC.isDarwin [ colima ];
}
