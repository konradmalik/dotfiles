-- https://github.com/sumneko/lua-language-server
local neodev_ok, neodev = pcall(require, "neodev")
if not neodev_ok then
    vim.notify("cannot load neodev")
    return false
end
neodev.setup({
    -- add any options here, or leave empty to use the default settings
})

return {
    settings = {
        Lua = {
            telemetry = { enable = false },
        }
    }
}
