{ stdenvNoCC, nerd-font-patcher }:
font:
stdenvNoCC.mkDerivation {
  pname = "${font.pname}-nerd-font";
  version = font.version;

  src = font;

  nativeBuildInputs = [ nerd-font-patcher ];

  dontFixup = true;
  dontInstall = true;

  buildPhase = ''
    mkdir -p $out
    find -name \*.ttf -exec nerd-font-patcher -o $out/share/fonts/truetype/ --no-progressbars --complete {} \;
    find -name \*.otf -exec nerd-font-patcher -o $out/share/fonts/opentype/ --no-progressbars --complete {} \;
  '';
}
