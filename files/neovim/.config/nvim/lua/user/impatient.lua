local impatient_ok, _ = pcall(require, "impatient")
if not impatient_ok then
    vim.notify("cannot load impatient")
    return
end
