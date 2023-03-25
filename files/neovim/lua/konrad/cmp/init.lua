local group = vim.api.nvim_create_augroup("CmpLazyLoad", { clear = true })
-- lazy load additional stuff, happens on InsertEnter
require("konrad.cmp.snippets")(group)
require("konrad.cmp.copilot")(group)

vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    desc = "Lazily initialize cmp",
    once = true,
    callback = function()
        vim.cmd('packadd nvim-cmp')
        vim.cmd('packadd cmp-buffer')
        vim.cmd('packadd cmp-path')
        vim.cmd('packadd cmp_luasnip')
        vim.cmd('packadd cmp-nvim-lsp')
        local cmp_status_ok, cmp = pcall(require, "cmp")
        if not cmp_status_ok then
            vim.notify("cannot load cmp")
            return
        end


        local kind_icons = require("konrad.icons").kind
        local menu_entries = {
            copilot = "[Copilot]",
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            buffer = "[Buffer]",
            path = "[Path]",
        }

        cmp.setup({
            snippet = {
                expand = function(args)
                    local ok, snip = pcall(require, "luasnip")
                    if not ok then
                        return
                    end
                    snip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-p>"] = cmp.mapping.select_prev_item(),
                ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<C-y>"] = cmp.mapping.confirm({
                    select = true,
                }),
            }),
            formatting = {
                fields = { "kind", "abbr", "menu" },
                format = function(entry, vim_item)
                    vim_item.kind = kind_icons[vim_item.kind]
                    vim_item.menu = menu_entries[entry.source.name]
                    return vim_item
                end,
            },
            sources = cmp.config.sources({
                { name = "copilot" },
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            }),
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
        })
    end
})
