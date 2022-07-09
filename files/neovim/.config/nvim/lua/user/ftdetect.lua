local ftdetect = vim.api.nvim_create_augroup("ftdetect", {clear=true})

vim.api.nvim_create_autocmd("BufRead,BufNewFile",
    { pattern = "Earthfile", command = "setfiletype Dockerfile", group = ftdetect })
vim.api.nvim_create_autocmd("BufRead,BufNewFile",
    { pattern = "Tiltfile", command = "set syntax=python", group = ftdetect })
