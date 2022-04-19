local npairs_status_ok, npairs = pcall(require, "nvim-autopairs")
if not npairs_status_ok then
    vim.notify("cannot load nvim-autopairs")
    return
end

npairs.setup({
    -- treesitter aware
    check_ts = true,
    ts_config = {
        --java = false, -- don't check treesitter on java
    },
    disable_filetype = { "TelescopePrompt" },
})

-- If you want to insert `(` after select function or method item
local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
    return
end

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
