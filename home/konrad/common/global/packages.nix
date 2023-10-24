{ pkgs, lib, ... }:
{
  home.packages = with pkgs;[
    dnsutils
    file
    inetutils
    moreutils
    progress
    tree
    stable.trurl
    unar
    wget
    zip

    ripgrep
    stable.ripgrep-all
    fd
    fpp
    sad
    sd
    urlscan

    hyperfine
    viddy
    watchexec
    yazi

    age
    fq
    dsq
    jc
    jo
    jq
    lnav
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
    tmux-sessionizer
    tmux-windowizer
  ] ++ lib.optionals pkgs.stdenvNoCC.isLinux [
    psmisc
    trace-cmd
  ];
}
