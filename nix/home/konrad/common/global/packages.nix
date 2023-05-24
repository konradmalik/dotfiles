{ pkgs, lib, ... }:
{
  home.packages = with pkgs;[
    dnsutils
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
    sad
    sd

    hyperfine
    viddy
    watchexec

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
    # konradmalik.rtx
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
