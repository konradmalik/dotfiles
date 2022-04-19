-- local colorscheme = "onedark"
local colorscheme = "dracula"
-- local colorscheme = "gruvbox"
local colorscheme_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme )
if not colorscheme_ok then
    vim.notify("cannot load colorscheme " .. colorscheme)
    return
end
