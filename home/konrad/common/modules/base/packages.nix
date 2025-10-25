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
    ]
    ++ (builtins.attrValues (import ../../../../../pkgs/scripts { inherit pkgs; }))
    ++ lib.optionals stdenvNoCC.isLinux [
      psmisc
      trace-cmd
    ]
    ++ lib.optionals stdenvNoCC.isDarwin [ colima ];
}
