-- https://github.com/sumneko/lua-language-server
local neodev_ok, neodev = pcall(require, "neodev")
if not neodev_ok then
    vim.notify("cannot load neodev")
else
    neodev.setup({
        -- add any options here, or leave empty to use the default settings
    })
end

return {
    settings = {
        Lua = {
            telemetry = { enable = false },
            hint = { enable = true },
        }
    }
}
