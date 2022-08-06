local catppuccin_ok, catppuccin = pcall(require, "catppuccin")
if not catppuccin_ok then
    return
end

vim.g.catppuccin_flavour = "macchiato" -- latte, frappe, macchiato, mocha

require("catppuccin").setup()

-- local colorscheme = "onedark"
-- local colorscheme = "gruvbox"
-- local colorscheme = "dracula"
local colorscheme = "catppuccin"
local colorscheme_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not colorscheme_ok then
    vim.notify("cannot load colorscheme " .. colorscheme)
    return
end
