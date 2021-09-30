local utils = require('utils')
-- Set completeopt to have a better completion experience
utils.opt('o', 'completeopt', 'menuone,noinsert,noselect')
-- Avoid showing message extra message when using completion
vim.cmd 'set shortmess+=c'
--vim.g.completion_confirm_key = ""
vim.g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy'}
-- <Tab> to navigate the completion menu
utils.map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', {expr = true})
utils.map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})
-- this prevents enter to create a new line when selecting
utils.map('i', '<CR>', 'pumvisible() ? "\\<C-y>" : "\\<C-g>u\\<CR>"', {expr = true})

-- setup sources
vim.g.completion_chain_complete_list = {
			default = {
                {complete_items = {'lsp', 'buffers', 'path'}},
            },
        }
-- other configs
vim.g.completion_sorting='none' --sorting
vim.g.completion_matching_smart_case = 1 -- smart case fuzzy matching
vim.g.completion_trigger_keyword_length = 1 -- default = 1
vim.g.completion_timer_cycle = 80 -- default value is 80
-- trigger it manually using smart tabulator
--vim.g.completion_enable_auto_popup = 0
--utils.map('i', '<S-Tab>', '<Plug>(completion_smart_s_tab)')
--utils.map('i', '<Tab>', '<Plug>(completion_smart_tab)')