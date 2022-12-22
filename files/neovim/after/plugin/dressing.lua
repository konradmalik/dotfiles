local dressing_ok, dressing = pcall(require, "dressing")
if not dressing_ok then
    vim.notify("cannot load dressing")
    return
end

dressing.setup({})
