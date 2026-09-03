local state = require("himalaya.state")
local picker = require("himalaya.ui.picker")
local folder = require("himalaya.folder")

local M = {}

function M.select()
	picker.select_account(function(choice)
		M.switch_to(choice.name)
	end)
end

function M.switch_to(account_name)
	state.current_account = account_name
	state.current_folder = "INBOX"
	state.current_page = 1
	vim.notify("Switched to account: " .. account_name, vim.log.levels.INFO)
	folder.reload()
end

return M
