{
  iosevka,
}:
iosevka.override {
  # https://github.com/be5invis/Iosevka/blob/main/doc/custom-build.md
  privateBuildPlan = {
    family = "Iosemka";

    spacing = "term";
    serifs = "sans";

    noCvSs = false;
    exportGlyphNames = false;

    variants = {
      inherits = "ss14";
    };

    ligations = {
      inherits = "dlig";
    };

    weights = {
      Regular = {
        shape = 400;
        menu = 400;
        css = 400;
      };
      Bold = {
        shape = 700;
        menu = 700;
        css = 700;
      };
    };

    widths = {
      Normal = {
        shape = 600;
        menu = 5;
        css = "normal";
      };
    };

    slopes = {
      Upright = {
        angle = 0;
        shape = "upright";
        menu = "upright";
        css = "normal";
      };

      Italic = {
        angle = 9.4;
        shape = "italic";
        menu = "italic";
        css = "italic";
      };
    };
  };
}
