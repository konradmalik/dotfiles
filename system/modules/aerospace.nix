{ config, lib, ... }:
let
  aerospace = lib.getExe config.home-manager.users.konrad.programs.aerospace.package;

  screenshot =
    flags:
    "exec-and-forget mkdir -p /tmp/screenshots && screencapture -i ${flags} /tmp/screenshots/$(date +%Y-%m-%d-%H%M%S).png";

  directions = {
    left = "h";
    down = "j";
    up = "k";
    right = "l";
  };

  directionBindings = lib.concatMapAttrs (
    dir: vimKey:
    lib.mergeAttrsList (
      map
        (key: {
          "alt-${key}" = "focus ${dir}";
          "alt-shift-${key}" = "move ${dir}";
          "alt-ctrl-${key}" = "focus-monitor ${dir}";
          "alt-ctrl-shift-${key}" = "move-node-to-monitor --focus-follows-window ${dir}";
          "alt-cmd-${key}" = "move-workspace-to-monitor ${dir}";
        })
        [
          dir
          vimKey
        ]
    )
  ) directions;

  # padded so they sort
  workspaceNames = lib.genList (i: lib.fixedWidthNumber 2 (i + 1)) 10;

  workspaceBindings = lib.mergeAttrsList (
    lib.imap1 (
      i: name:
      let
        key = toString (lib.mod i 10);
      in
      {
        "alt-${key}" = "workspace ${name}";
        "alt-shift-${key}" = "move-node-to-workspace ${name}";
      }
    ) workspaceNames
  );

  scratchpad = "S";
in
{
  # home-manager's module rather than nix-darwin's: nix-darwin passes the config to
  # launchd as a store path, so every change restarted aerospace and lost window placement,
  # home-manager keeps it in ~/.config and runs reload-config when it changes
  home-manager.users.konrad.programs.aerospace = {
    enable = true;
    launchd.enable = true;
    settings = {
      config-version = 2;
      # like the hyprland bar, first five always exist, the rest only while they have windows
      persistent-workspaces = lib.take 5 workspaceNames;

      # inner is the whole gap between windows, unlike hyprland's per-window gaps_in,
      # so it matches outer for even spacing (hyprland's 5 in / 10 out looks the same)
      gaps = {
        inner = {
          horizontal = 10;
          vertical = 10;
        };
        outer = {
          left = 10;
          bottom = 10;
          # the menu bar already separates windows from the screen edge
          top = 0;
          right = 10;
        };
      };

      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      mode.main.binding = {
        # Program bindings
        # a running ghostty gets a new window over applescript (open -n would add another
        # instance and dock icon); open hands its env to the app, and the
        # exec-and-forget shell's SHLVL would start every terminal at 2
        alt-enter = "exec-and-forget pgrep -xq ghostty && osascript -e 'tell application \"Ghostty\"' -e 'new window' -e 'activate' -e 'end tell' || env -u SHLVL open -a Ghostty";
        # held alt would otherwise put Zen into Troubleshoot Mode on launch
        alt-b = "exec-and-forget open --env MOZ_DISABLE_SAFE_MODE_KEY=1 -a '${config.users.users.konrad.home}/Applications/Home Manager Apps/Zen Browser (Beta).app'";

        # Screenshots
        alt-p = screenshot "";
        # annotate in preview
        alt-shift-p = screenshot "-P";

        # Window manager controls
        alt-shift-q = "close";
        alt-f = "fullscreen";
        alt-shift-f = "macos-native-fullscreen";
        alt-shift-space = "layout floating tiling";
        alt-minus = "resize smart -50";
        alt-shift-minus = "resize smart -70";
        alt-equal = "resize smart +50";
        alt-shift-equal = "resize smart +70";

        alt-g = "layout accordion tiles";

        # Cycle / swap windows
        alt-tab = "focus --boundaries-action wrap-around-the-workspace dfs-next";
        alt-shift-tab = "focus --boundaries-action wrap-around-the-workspace dfs-prev";
        alt-ctrl-tab = "swap --wrap-around dfs-next";
        alt-ctrl-shift-tab = "swap --wrap-around dfs-prev";

        # Scratchpad
        alt-u = "exec-and-forget [ \"$(${aerospace} list-workspaces --focused)\" = ${scratchpad} ] && ${aerospace} workspace-back-and-forth || ${aerospace} workspace ${scratchpad}";
        alt-shift-u = "move-node-to-workspace ${scratchpad}";
      }
      // directionBindings
      // workspaceBindings;
    };
  };

  system.defaults = {
    # recommended by aerospace, turns off "displays have separate spaces" (needs a logout)
    spaces.spans-displays = true;
    # menu bar workspace indicator, "i3 style grouped" in the UI
    CustomUserPreferences."bobko.aerospace".displayStyle = "i3";
    WindowManager = {
      # macOS's own tiling fights aerospace when dragging windows
      EnableTilingByEdgeDrag = false;
      EnableTopTilingByEdgeDrag = false;
      EnableTilingOptionAccelerator = false;
      # clicking the wallpaper in a gap would sweep every window away
      EnableStandardClickToShowDesktop = false;
    };
    # ctrl-cmd + drag moves a window from anywhere, like hyprland's super + drag (needs a logout)
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;
  };
}
