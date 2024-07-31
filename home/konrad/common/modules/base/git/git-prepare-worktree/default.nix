{
  git,
  writeScriptBin,
  symlinkJoin,
  makeWrapper,
}:
let
  name = "git-prepare-worktree";
  script = (writeScriptBin name (builtins.readFile ./git-prepare-worktree.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
  deps = [ git ];
in
symlinkJoin {
  inherit name;
  paths = [ script ] ++ deps;
  buildInputs = [ makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
