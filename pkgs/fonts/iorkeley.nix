{
  iosevka,
}:
# Iosevka configured to mimic Berkeley Mono, ported from IoskeleyMono:
# https://github.com/ahatem/IoskeleyMono
# and modified accordingly
iosevka.override {
  # https://github.com/be5invis/Iosevka/blob/main/doc/custom-build.md
  privateBuildPlan = {
    family = "Iorkeley";

    spacing = "term";
    serifs = "sans";

    noCvSs = true;
    exportGlyphNames = false;

    noLigation = true;

    variants = {
      design = {
        one = "no-base";
        two = "straight-neck-serifless";
        three = "flat-top-serifless";
        four = "semi-open-serifless";
        five = "oblique-flat-serifless";
        six = "open-contour";
        seven = "straight-serifless";
        eight = "two-circles";
        nine = "open-contour";
        zero = "dotted";
        capital-a = "straight-serifless";
        capital-b = "standard-serifless";
        capital-c = "bilateral-inward-serifed";
        capital-d = "standard-serifless";
        capital-e = "serifless";
        capital-f = "serifless";
        capital-g = "toothless-corner-inward-serifed-hooked";
        capital-h = "serifless";
        capital-i = "serifed";
        capital-j = "serifless";
        capital-k = "symmetric-touching-serifless";
        capital-l = "serifless";
        capital-m = "hanging-serifless";
        capital-n = "standard-serifless";
        capital-p = "closed-serifless";
        capital-q = "crossing";
        capital-r = "standing-serifless";
        capital-s = "serifless";
        capital-t = "serifless";
        capital-u = "toothless-rounded-serifless";
        capital-v = "straight-serifless";
        capital-w = "straight-flat-top-serifless";
        capital-x = "straight-serifless";
        capital-y = "straight-serifless";
        capital-z = "straight-serifless";
        a = "double-storey-serifless";
        b = "toothed-serifless";
        c = "bilateral-inward-serifed";
        d = "toothed-serifless";
        e = "flat-crossbar";
        f = "flat-hook-serifless-crossbar-at-x-height";
        g = "single-storey-serifless";
        h = "straight-serifless";
        i = "serifed";
        j = "flat-hook-serifed";
        k = "symmetric-touching-serifless";
        l = "serifed";
        m = "serifless";
        n = "straight-serifless";
        p = "eared-serifless";
        q = "straight-serifless";
        r = "hookless-serifless";
        s = "serifless";
        t = "flat-hook-short-neck2";
        u = "toothed-serifless";
        v = "straight-serifless";
        w = "straight-flat-top-serifless";
        x = "straight-serifless";
        y = "straight-serifless";
        z = "straight-serifless";
        lower-theta = "oval";
        tittle = "square";
        diacritic-dot = "square";
        punctuation-dot = "square";
        braille-dot = "square";
        tilde = "low";
        asterisk = "penta-mid";
        underscore = "high";
        caret = "medium";
        ascii-grave = "straight";
        ascii-single-quote = "straight";
        paren = "flat-arc";
        brace = "curly-flat-boundary";
        guillemet = "straight";
        number-sign = "slanted";
        ampersand = "closed";
        at = "fourfold";
        dollar = "through";
        cent = "through-cap";
        percent = "rings-continuous-slash";
        bar = "natural-slope";
        question = "corner";
        pilcrow = "high";
        micro-sign = "toothed-serifless";
        decorative-angle-brackets = "middle";
        lig-ltgteq = "slanted";
        lig-neq = "slightly-slanted";
        lig-equal-chain = "without-notch";
        lig-hyphen-chain = "without-notch";
        lig-plus-chain = "without-notch";
        lig-double-arrow-bar = "without-notch";
        lig-single-arrow-bar = "without-notch";
      };
    };

    metricOverride = {
      xHeight = 520;
      cap = 690;
      ascender = 740;
      sb = 85;

      accentWidth = 182;
      accentClearance = 76;
      accentHeight = 162;
      accentStackOffset = 208;

      leading = 1250;
      parenSize = 860;
      dotSize = "blend(weight, [100, 110], [400, 125], [900, 150])";
      periodSize = 140;

      essRatio = 1.03;
      essRatioUpper = 1.03;
      essRatioLower = 1.03;
      essRatioQuestion = 1.03;
      archDepth = 152;
      smallArchDepth = 157;
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
        angle = 11.8;
        shape = "italic";
        menu = "italic";
        css = "italic";
      };
    };
  };
}
