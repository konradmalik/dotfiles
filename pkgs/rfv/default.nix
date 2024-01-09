{ ripgrep
, bat
, fzf
, writeScriptBin
, symlinkJoin
, makeWrapper
}:
let
  name = "rfv";
  script = (writeScriptBin name (builtins.readFile ./rfv.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
  deps = [ ripgrep bat fzf ];
in
symlinkJoin {
  inherit name;
  paths = [ script ] ++ deps;
  buildInputs = [ makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
