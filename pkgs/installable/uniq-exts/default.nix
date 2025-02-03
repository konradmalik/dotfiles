{
  coreutils,
  findutils,
  perl,
  writeScriptBin,
  symlinkJoin,
  makeWrapper,
}:
let
  name = "uniq-exts";
  script = (writeScriptBin name (builtins.readFile ./uniq-exts.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
  deps = [
    coreutils
    findutils
    perl
  ];
in
symlinkJoin {
  inherit name;
  paths = [ script ] ++ deps;
  buildInputs = [ makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
