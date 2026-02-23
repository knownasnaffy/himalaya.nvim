-- Keybindings for himalaya-envelope-listing buffer
local bufnr = vim.api.nvim_get_current_buf()

-- Close window
vim.keymap.set("n", "gq", function()
	require("himalaya").close()
end, { buffer = bufnr, desc = "Close Himalaya" })

-- Next folder (supports count)
vim.keymap.set("n", "]f", function()
	local count = vim.v.count1
	local folder_mod = require("himalaya.folder")

	-- Navigate without reload for all but the last
	for i = 1, count - 1 do
		folder_mod.next(true, true) -- silent, skip_reload
	end

	-- Final navigation with reload and notification
	folder_mod.next(false, false)
end, { buffer = bufnr, desc = "Next folder" })

-- Previous folder (supports count)
vim.keymap.set("n", "[f", function()
	local count = vim.v.count1
	local folder_mod = require("himalaya.folder")

	-- Navigate without reload for all but the last
	for i = 1, count - 1 do
		folder_mod.previous(true, true) -- silent, skip_reload
	end

	-- Final navigation with reload and notification
	folder_mod.previous(false, false)
end, { buffer = bufnr, desc = "Previous folder" })

-- Folder picker
vim.keymap.set("n", "gF", function()
	require("himalaya.folder").picker()
end, { buffer = bufnr, desc = "Folder picker" })

-- Reload emails
vim.keymap.set("n", "gr", function()
	require("himalaya.folder").reload()
end, { buffer = bufnr, desc = "Reload emails" })
