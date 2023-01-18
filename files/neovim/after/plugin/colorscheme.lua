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

vim.api.nvim_command('packadd mini')
local mini_base16_ok, mini_base16 = pcall(require, "mini.base16")
if not mini_base16_ok then
    vim.notify("cannot load mini.base16")
    return
end

mini_base16.setup({
    palette = nix_colors.colors
})
