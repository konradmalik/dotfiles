{ pkgs, lib, ... }:

let
  unpackaged = pkgs.callPackage ./unpackaged.nix { };
  source = pkgs.unstable.vimPlugins // unpackaged;
  makePlugin = plugin:
    let
      makeAttrset = p: if builtins.hasAttr "plugin" p then p else { plugin = p; };
      hasDeps = s: builtins.hasAttr "dependencies" s;
      pluginAttrset = makeAttrset plugin;
      dependencies = if hasDeps pluginAttrset then pluginAttrset.dependencies else [ ];
      dependenciesAttrsets = builtins.map makeAttrset dependencies;
    in
    dependenciesAttrsets ++ [ (lib.filterAttrs (n: v: n != "dependencies") pluginAttrset) ];
  processMadePlugins = madePlugins: lib.unique (lib.flatten madePlugins);
in
processMadePlugins (with source; [
  # treesitter
  (makePlugin
    {
      plugin = nvim-treesitter.withAllGrammars;
      dependencies = [ nvim-treesitter-context nvim-treesitter-textobjects ];
    })
  # completion
  (makePlugin
    {
      plugin = nvim-cmp;
      dependencies = [ cmp-buffer cmp-nvim-lsp cmp-path cmp_luasnip { plugin = luasnip; optional = true; } { plugin = friendly-snippets; optional = true; } ];
    })
  # lsp
  (makePlugin
    {
      plugin = nvim-lspconfig;
      dependencies = [ null-ls-nvim neodev-nvim fidget-nvim ];
    })
  # dap
  (makePlugin
    {
      plugin = nvim-dap;
      dependencies = [
        {
          plugin = nvim-dap-ui;
          optional = true;
        }
        {
          plugin = nvim-dap-virtual-text;
          optional = true;
        }
      ];
      optional = true;
    })
  # telescope
  (makePlugin
    {
      plugin = telescope-nvim;
      dependencies = [ plenary-nvim telescope-fzf-native-nvim ];
    })
  # statusline
  (makePlugin
    {
      plugin = heirline-nvim;
      dependencies = [ nvim-web-devicons { plugin = nvim-navic; optional = true; } ];
    })
  # ui
  (makePlugin catppuccin-nvim)
  (makePlugin { plugin = mini-base16; optional = true; })
  (makePlugin dressing-nvim)
  (makePlugin
    {
      plugin = neo-tree-nvim;
      dependencies = [ nvim-web-devicons plenary-nvim nui-nvim ];
    })
  # misc
  (makePlugin boole-nvim)
  (makePlugin comment-nvim)
  (makePlugin
    {
      plugin = diffview-nvim;
      dependencies = [ plenary-nvim nvim-web-devicons ];
    })
  (makePlugin
    {
      plugin = gitsigns-nvim;
      dependencies = [ nvim-web-devicons ];
    })
  (makePlugin harpoon)
  (makePlugin impatient-nvim)
  (makePlugin indent-blankline-nvim)
  (makePlugin nvim-luaref)
  (makePlugin SchemaStore-nvim)
  (makePlugin vim-sleuth)
  (makePlugin which-key-nvim)
])