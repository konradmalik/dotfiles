{ pkgs, lib, ... }:
{
  home.packages = with pkgs;[
    dnsutils
    file
    inetutils
    moreutils
    #nq
    unstable.progress
    tree
    unstable.trurl
    unar
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
    viddy
    watchexec
    joshuto

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