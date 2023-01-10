{ runCommand, remarshal }:
let
  fromYAML = yaml: builtins.fromJSON (
    builtins.readFile (
      runCommand "from-yaml"
        {
          inherit yaml;
          allowSubstitutes = false;
          preferLocalBuild = true;
        }
        ''
          ${remarshal}/bin/remarshal  \
            -if yaml \
            -i <(echo "$yaml") \
            -of json \
            -o $out
        ''
    )
  );
  readYAML = path: fromYAML (builtins.readFile path);
in
{
  inherit fromYAML readYAML;
}
