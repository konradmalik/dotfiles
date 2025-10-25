{ pkgs }:
let
  wrapScript =
    {
      name,
      file,
      deps ? [ ],
    }:
    let
      script = (pkgs.writeScriptBin name (builtins.readFile file)).overrideAttrs (old: {
        buildCommand = "${old.buildCommand}\n patchShebangs $out";
      });
    in
    pkgs.symlinkJoin {
      inherit name;
      paths = [ script ] ++ deps;
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
    };

  scriptsToAttr =
    scripts:
    builtins.listToAttrs (
      map (
        input:
        let
          filename = builtins.baseNameOf input.file;
          name = builtins.head (builtins.split "\\." filename);
        in
        {
          inherit name;
          value = wrapScript (
            input
            // {
              inherit name;
            }
          );
        }
      ) scripts
    );
in
scriptsToAttr [
  {
    file = ./realize-symlink.sh;
    deps = [ pkgs.coreutils ];
  }
  {
    file = ./terminal-testdrive.sh;
    deps = with pkgs; [
      bc
      gawk
    ];
  }
  {
    file = ./uniq-exts.sh;
    deps = with pkgs; [
      coreutils
      findutils
      perl
    ];
  }
]
