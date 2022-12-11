{ buildEnv
, pkgs
}:
let
  # can be here as it's not really system dependent
  # if ever becomes that - we can move it to outputs and refer to it as 'self.profileExports.${system}'
  profileExports = pkgs.writeText "profile-exports" ''
    export MANPATH=$HOME/.nix-profile/share/man:/nix/var/nix/profiles/default/share/man:/usr/share/man
    export INFOPATH=$HOME/.nix-profile/share/info:/nix/var/nix/profiles/default/share/info:/usr/share/info
  '';
in
{
  home = buildEnv
    {
      name = "konrad-home-env";
      paths = [
        (pkgs.runCommand "profile" { } ''
          mkdir -p $out/etc/profile.d
          cp ${profileExports} $out/etc/profile.d/profile-exports.sh
        '')

        pkgs.direnv
        pkgs.nix-direnv
      ];
      pathsToLink = [ "/share" "/bin" "/etc" ];
      extraOutputsToInstall = [ "man" "doc" "info" ];
      postBuild = ''
        if [ -x $out/bin/install-info -a -w $out/share/info ]; then
          shopt -s nullglob
          for i in $out/share/info/*.info $out/share/info/*.info.gz; do
              $out/bin/install-info $i $out/share/info/dir
          done
        fi
      '';
    };
}
