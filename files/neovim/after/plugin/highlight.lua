local highlight_ok, highlight = pcall(require, "local-highlight")
if not highlight_ok then
    vim.notify("cannot load highlight")
    return
end

highlight.setup({ cw_hlgroup = nil, })
