{ pkgs, projectsDir, ... }:
let
  name = "tms";
  script = (pkgs.writeScriptBin name (builtins.readFile ./tmux-sessionizer.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
  deps = with pkgs; [
    tmux
    fzf
    coreutils
  ];
in
pkgs.symlinkJoin {
  inherit name;
  paths = [ script ] ++ deps;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin --set-default TMS_ROOT ${projectsDir}";
}
