local boole_ok, boole = pcall(require, "boole")
if not boole_ok then
    return
end

boole.setup({
    mappings = {
        increment = '<C-a>',
        decrement = '<C-x>'
    },
    -- User defined loops
    additions = {
        -- {'Foo', 'Bar'},
        -- {'tic', 'tac', 'toe'}
    },
})
