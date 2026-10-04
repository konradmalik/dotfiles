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
      openssl
      rsync
      tree
      unixtools.xxd
      wget

      fd
      ripgrep

      dua
      procs

      jq
    ]
    ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
      psmisc
    ];
}
