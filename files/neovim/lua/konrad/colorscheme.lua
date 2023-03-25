-- injected via nix.
local nix_colors_ok, nix_colors = pcall(require, "konrad.nix-colors")
if not nix_colors_ok then
    vim.notify("cannot load nix-colors")
    return
end

local colorscheme = nix_colors.slug;
if string.find(colorscheme, "catppuccin") then

    local catppuccin_ok, catppuccin = pcall(require, "catppuccin")
    if not catppuccin_ok then
        vim.notify("cannot load catppuccin")
        return
    end

    catppuccin.setup({
        flavour = vim.split(colorscheme, "-")[2],
        -- required to override default cache which is repo path - fails in nix (/nix/store)
        compile_path = vim.fn.stdpath "cache" .. "/catppuccin",
        integrations = {
            indent_blankline = {
                enabled = true,
            },
            native_lsp = {
                enabled = true,
            },
        },
    })

    vim.cmd.colorscheme "catppuccin"
    return
else
    local colorscheme_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
    if colorscheme_ok then
        return
    else
        vim.notify("cannot load colorscheme " .. colorscheme)
    end
end

vim.cmd('packadd mini.base16')
local mini_base16_ok, mini_base16 = pcall(require, "mini.base16")
if not mini_base16_ok then
    vim.notify("cannot load mini.base16")
    return
end

mini_base16.setup({
    palette = nix_colors.colors
})
