{ pkgs, lib, ... }:
{
  home.packages =
    with pkgs;
    [
      curl
      dnsutils
      file
      inetutils
      moreutils
      progress
      tree
      trurl
      unar
      unixtools.xxd
      wget
      zip

      fd
      fpp
      ripgrep
      ripgrep-all
      sad
      sd

      baywatch
      hyperfine
      noti
      spacer
      viddy
      yazi

      age
      fq
      dsq
      jc
      jo
      jq
      xsv
      yq-go

      du-dust
      duf
      procs

      croc
      gh
      glab
      up

      rfv
      realize-symlink
      terminal-testdrive
    ]
    ++ lib.optionals stdenvNoCC.isLinux [
      psmisc
      trace-cmd
    ]
    ++ lib.optionals stdenvNoCC.isDarwin [ colima ];
}
