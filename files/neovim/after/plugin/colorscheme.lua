local base16_colorscheme_ok, base16_colorscheme = pcall(require, "base16-colorscheme")
if not base16_colorscheme_ok then
    vim.notify("cannot load base16-colorscheme")
    return
end

-- injected via nix. If not, we just fallback
local nix_colors_ok, nix_colors = pcall(require, "konrad.nix-colors")
if not nix_colors_ok then
    -- fallback
    local colorscheme = "base16-catppuccin"
    local colorscheme_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
    if not colorscheme_ok then
        vim.notify("cannot load fallback colorscheme " .. colorscheme)
        return
    end
end

base16_colorscheme.setup(nix_colors)
