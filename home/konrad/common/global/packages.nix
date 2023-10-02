{ pkgs, lib, ... }:
{
  home.packages = with pkgs;[
    dnsutils
    file
    inetutils
    moreutils
    #nq
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

    nodePackages.prettier
    shfmt
  ] ++ lib.optionals pkgs.stdenvNoCC.isLinux [
    psmisc
    trace-cmd
  ];
}
