{ pkgs, lib, ... }:
{
  home.packages = with pkgs;[
    curl
    dnsutils
    moreutils
    nq
    tree
    unstable.trurl
    unar
    wget
    zip

    ripgrep
    ripgrep-all
    fd
    # fix for aarch64 is only on unstable as of now
    unstable.sad
    sd

    hyperfine
    viddy
    watchexec

    age
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
  ];
}
