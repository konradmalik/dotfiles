require("buftabline").setup {
    modifier = ":t",
    index_format = "%d: ",
    padding = 1,
    icons = true,
    start_hidden = false,
    auto_hide = true,
    disable_commands = false,
    go_to_maps = false,
    kill_maps = false,
    custom_command = nil,
    custom_map_prefix = nil,
    -- for below groups see your theme source
    -- https://github.com/joshdick/onedark.vim/blob/master/colors/onedark.vim
    hlgroup_current = "TabLineSel",
    hlgroup_normal = "TabLine",
}

