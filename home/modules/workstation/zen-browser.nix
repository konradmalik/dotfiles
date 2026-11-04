{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.zen-browser;
in
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;
    # mime defaults and $BROWSER, darwin keeps its own default browser
    setAsDefaultBrowser = pkgs.stdenv.hostPlatform.isLinux;

    # id 0, so it is the default one
    profiles.default = {
      # only prefs Firefox Sync does not carry, synced ones come from the account
      settings = {
        "browser.ml.linkPreview.enabled" = true;
        "browser.search.suggest.enabled" = true;
        "browser.search.suggest.enabled.private" = true;
        "browser.translations.neverTranslateLanguages" = "pl";
        "dom.forms.autocomplete.formautofill" = true;
        "zen.library.media.enabled" = true;
        "zen.view.compact.enable-at-startup" = false;
        "zen.view.sidebar-expanded" = false;
        "zen.view.use-single-toolbar" = false;
        "zen.window-sync.sync-only-pinned-tabs" = true;
        "zen.workspaces.continue-where-left-off" = true;
      };

      search = {
        force = true;
        default = "google";
        engines = {
          bing.metaData.hidden = true;
          ddg.metaData.hidden = true;
          perplexity.metaData.hidden = true;
        };
      };

      extensionButtons."nav-bar" = [ "{446900e4-71c2-419f-a6a7-df9c091e268b}" ];
    };

    policies = {
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      # bitwarden handles passwords
      PasswordManagerEnabled = false;
      ExtensionSettings =
        builtins.mapAttrs
          (_: slug: {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
            installation_mode = "force_installed";
          })
          {
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
            "uBlock0@raymondhill.net" = "ublock-origin";
            "harper@writewithharper.com" = "private-grammar-checker-harper";
            "{2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c}" = "search_by_image";
            "pl@dictionaries.addons.mozilla.org" = "polish-spellchecker-dictionary";
          };
    };
  };

  stylix.targets.zen-browser.profileNames = [ "default" ];

  # fail the build when Zen no longer references a declared pref (renamed or removed upstream)
  home.extraDependencies = [
    (pkgs.runCommand "zen-prefs-check"
      {
        nativeBuildInputs = [ pkgs.unzip ];
        prefs = lib.attrNames cfg.profiles.default.settings;
      }
      ''
        # omni.ja holds Zen's JS, its non-standard zip header makes unzip warn;
        # split on quotes so each pref name is a whole line, no prefix matches
        find -L ${cfg.package} -name omni.ja -exec unzip -p {} \; 2>/dev/null \
          | tr "\"'" '\n\n' > strings
        if [ ! -s strings ]; then
          echo "zen-prefs-check: no omni.ja found in ${cfg.package.name}"
          exit 1
        fi
        missing=
        for p in $prefs; do
          grep -qaxF "$p" strings || missing="$missing $p"
        done
        if [ -n "$missing" ]; then
          echo "zen-prefs-check: not referenced by ${cfg.package.name}:$missing"
          exit 1
        fi
        touch $out
      ''
    )
  ];
}
