local utils = require("user.utils")
local api = vim.api

function nvim_create_augroups(definitions)
	for group_name, definition in pairs(definitions) do
		api.nvim_command("augroup " .. group_name)
		api.nvim_command("autocmd!")
		for _, def in ipairs(definition) do
			-- if type(def) == 'table' and type(def[#def]) == 'function' then
			-- 	def[#def] = lua_callback(def[#def])
			-- end
			local command = table.concat(vim.tbl_flatten({ "autocmd", def }), " ")
			api.nvim_command(command)
		end
		api.nvim_command("augroup END")
	end
end

local autocmds = {
	personal = {
		{ "BufWritePre", "*", "lua require('user.utils').trim_trailing_whitespace()" },
		{ "DiagnosticChanged", "*", "lua vim.diagnostic.setloclist({ open = false })" },
	},
	packer_user_config = {
		{ "BufWritePost", "plugins.lua", "source <afile> | PackerSync" },
	},
}

nvim_create_augroups(autocmds)
