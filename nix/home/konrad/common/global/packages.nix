{ pkgs, lib, ... }:
{
  home.packages = with pkgs;[
    curl
    moreutils
    nq
    tree
    unzip
    wget

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
    jq
    jo
    jc
    xsv

    du-dust
    duf
    procs

    croc
    up

    awscli
    azure-cli

    dive

    asdf-vm
    comma
  ] ++ lib.optionals pkgs.stdenvNoCC.isLinux [
    psmisc
  ];
}
