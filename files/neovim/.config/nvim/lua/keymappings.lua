local utils = require('utils')

-- <Tab> to navigate buffers in normal mode
utils.map('n', '<S-Tab>', ':bp<CR>')
utils.map('n', '<Tab>', ':bn<CR>')
