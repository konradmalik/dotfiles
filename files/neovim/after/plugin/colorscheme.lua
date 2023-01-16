-- injected via nix.
local nix_colors_ok, nix_colors = pcall(require, "konrad.nix-colors")
if not nix_colors_ok then
    vim.notify("cannot load nix-colors")
    return
end

local colorscheme = nix_colors.slug;
local colorscheme_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if colorscheme_ok then
    return
else
    vim.notify("cannot load colorscheme " .. colorscheme)
end

local base16_colorscheme_ok, base16_colorscheme = pcall(require, "base16-colorscheme")
if not base16_colorscheme_ok then
    vim.notify("cannot load base16-colorscheme")
    return
end

base16_colorscheme.setup(nix_colors.colors)
