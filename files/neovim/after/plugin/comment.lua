local comment_ok, comment = pcall(require, "Comment")
if not comment_ok then
    vim.notify("cannot load Comment")
    return
end

comment.setup({
    mappings = {
        basic = true,
        extra = false,
    },
})
