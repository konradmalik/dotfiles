{ pkgs, ... }:
let
  name = "tmux-switcher";
  script = (pkgs.writeScriptBin name (builtins.readFile ./tmux-switcher.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
  deps = with pkgs; [ tmux coreutils ];
in
pkgs.symlinkJoin {
  inherit name;
  paths = [ script ] ++ deps;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
