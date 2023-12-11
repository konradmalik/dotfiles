{ pkgs, lib, ... }:
{
  home.packages = with pkgs;[
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

    ripgrep
    ripgrep-all
    fd
    fpp
    sad
    sd
    urlscan

    hyperfine
    noti
    viddy
    baywatch
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
  ] ++ lib.optionals pkgs.stdenvNoCC.isLinux [
    psmisc
    trace-cmd
  ];
}
