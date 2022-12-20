local impatient_ok, impatient = pcall(require, "impatient")
if not impatient_ok then
    vim.notify("cannot load impatient")
    return
end

-- enable profiling, only if needed
-- impatient.enable_profile()
