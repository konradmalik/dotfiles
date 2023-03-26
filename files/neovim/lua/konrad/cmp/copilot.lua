require("copilot").setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
})
local fmt = require('copilot_cmp.format')
require("copilot_cmp").setup({
    formatters = {
        label = fmt.format_label_text,
        -- insert_text = fmt.format_insert_text,
        insert_text = fmt.remove_existing,
        preview = fmt.deindent,
    },
})
