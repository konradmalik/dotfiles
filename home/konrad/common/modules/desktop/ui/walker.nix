{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.walker = {
    enable = true;
    systemd = true;
    settings = {
      force_keyboard_focus = true;
      selection_wrap = true;

      shell = {
        anchor_top = true;
        anchor_bottom = true;
        anchor_left = true;
        anchor_right = true;
      };

      placeholders = {
        "default" = {
          input = "Search";
          list = "No Results";
        };
      };

      keybinds = {
        close = [ "Escape" ];
        next = [ "Down" ];
        previous = [ "Up" ];
        toggle_exact = [ "ctrl e" ];
        resume_last_query = [ "ctrl r" ];
        quick_activate = [
          "F1"
          "F2"
          "F3"
          "F4"
        ];
      };

      providers = {
        default = [
          "desktopapplications"
          "calc"
          "runner"
          "menus"
          "websearch"
        ];
        empty = [ "desktopapplications" ];
        max_results = 50;

        sets = { };
        max_results_provider = { };

        prefixes = [
          {
            prefix = ";";
            provider = "providerlist";
          }
          {
            prefix = "/";
            provider = "files";
          }
          {
            prefix = ".";
            provider = "symbols";
          }
          {
            prefix = "!";
            provider = "todo";
          }
          {
            prefix = "=";
            provider = "calc";
          }
          {
            prefix = "@";
            provider = "websearch";
          }
          {
            prefix = ":";
            provider = "clipboard";
          }
        ];

        clipboard = {
          time_format = "%d.%m. - %H:%M";
        };

        actions = {
          dmenu = [
            {
              action = "select";
              default = true;
              bind = "Return";
            }
          ];

          providerlist = [
            {
              action = "activate";
              default = true;
              bind = "Return";
              after = "ClearReload";
            }
          ];

          bluetooth = [
            {
              action = "find";
              global = true;
              bind = "ctrl f";
              after = "AsyncClearReload";
            }
            {
              action = "trust";
              bind = "ctrl t";
              after = "AsyncReload";
            }
            {
              action = "untrust";
              bind = "ctrl t";
              after = "AsyncReload";
            }
            {
              action = "pair";
              bind = "Return";
              after = "AsyncReload";
            }
            {
              action = "remove";
              bind = "ctrl d";
              after = "AsyncReload";
            }
            {
              action = "connect";
              bind = "Return";
              after = "AsyncReload";
            }
            {
              action = "disconnect";
              bind = "Return";
              after = "AsyncReload";
            }
          ];

          archlinuxpkgs = [
            {
              action = "install";
              bind = "Return";
              default = true;
            }
            {
              action = "remove";
              bind = "Return";
            }
          ];

          calc = [
            {
              action = "copy";
              default = true;
              bind = "Return";
            }
            {
              action = "delete";
              bind = "ctrl d";
              after = "AsyncReload";
            }
            {
              action = "save";
              bind = "ctrl s";
              after = "AsyncClearReload";
            }
          ];

          websearch = [
            {
              action = "search";
              default = true;
              bind = "Return";
            }
            {
              action = "erase_history";
              label = "clear hist";
              bind = "ctrl h";
              after = "Reload";
            }
          ];

          desktopapplications = [
            {
              action = "start";
              default = true;
              bind = "Return";
            }
            {
              action = "start";
              label = "open+next";
              bind = "shift Return";
              after = "KeepOpen";
            }
            {
              action = "erase_history";
              label = "clear hist";
              bind = "ctrl h";
              after = "AsyncReload";
            }
            {
              action = "pin";
              bind = "ctrl p";
              after = "AsyncReload";
            }
            {
              action = "unpin";
              bind = "ctrl p";
              after = "AsyncReload";
            }
            {
              action = "pinup";
              bind = "ctrl n";
              after = "AsyncReload";
            }
            {
              action = "pindown";
              bind = "ctrl m";
              after = "AsyncReload";
            }
          ];

          files = [
            {
              action = "open";
              default = true;
              bind = "Return";
            }
            {
              action = "opendir";
              label = "open dir";
              bind = "ctrl Return";
            }
            {
              action = "copypath";
              label = "copy path";
              bind = "ctrl shift c";
            }
            {
              action = "copyfile";
              label = "copy file";
              bind = "ctrl c";
            }
          ];

          todo = [
            {
              action = "save";
              default = true;
              bind = "Return";
              after = "ClearReload";
            }
            {
              action = "delete";
              bind = "ctrl d";
              after = "ClearReload";
            }
            {
              action = "active";
              bind = "Return";
              after = "ClearReload";
            }
            {
              action = "inactive";
              bind = "Return";
              after = "ClearReload";
            }
            {
              action = "done";
              bind = "ctrl f";
              after = "ClearReload";
            }
            {
              action = "clear";
              bind = "ctrl x";
              after = "ClearReload";
              global = true;
            }
          ];

          runner = [
            {
              action = "run";
              default = true;
              bind = "Return";
            }
            {
              action = "runterminal";
              label = "run in terminal";
              bind = "shift Return";
            }
            {
              action = "erase_history";
              label = "clear hist";
              bind = "ctrl h";
              after = "Reload";
            }
          ];

          symbols = [
            {
              action = "run_cmd";
              label = "select";
              default = true;
              bind = "Return";
            }
            {
              action = "erase_history";
              label = "clear hist";
              bind = "ctrl h";
              after = "Reload";
            }
          ];

          unicode = [
            {
              action = "run_cmd";
              label = "select";
              default = true;
              bind = "Return";
            }
            {
              action = "erase_history";
              label = "clear hist";
              bind = "ctrl h";
              after = "Reload";
            }
          ];

          clipboard = [
            {
              action = "copy";
              default = true;
              bind = "Return";
            }
            {
              action = "remove";
              bind = "ctrl d";
              after = "ClearReload";
            }
            {
              action = "remove_all";
              global = true;
              label = "clear";
              bind = "ctrl shift d";
              after = "ClearReload";
            }
            {
              action = "toggle_images";
              global = true;
              label = "toggle images";
              bind = "ctrl i";
              after = "ClearReload";
            }
            {
              action = "edit";
              bind = "ctrl o";
            }
          ];
        };
      };
    };
  };
}
