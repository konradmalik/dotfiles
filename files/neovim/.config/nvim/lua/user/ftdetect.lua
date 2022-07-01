local utils = require('user.utils')

local autocmds = {
    ftdetect = {
        { "BufRead,BufNewFile", "Earthfile", "setfiletype Dockerfile" },
        { "BufRead,BufNewFile", "Tiltfile", "set syntax=python" },
    },
}

utils.nvim_create_augroups(autocmds)
