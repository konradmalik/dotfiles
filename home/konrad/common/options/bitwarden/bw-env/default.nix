{
  bitwarden-cli,
  jq,
  coreutils,
  writeScriptBin,
  symlinkJoin,
  makeWrapper,
}:
let
  name = "bw-env";
  script = (writeScriptBin name (builtins.readFile ./bw-env.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
  deps = [
    bitwarden-cli
    jq
    coreutils
  ];
in
symlinkJoin {
  inherit name;
  paths = [ script ] ++ deps;
  buildInputs = [ makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
