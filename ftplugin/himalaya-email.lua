-- Keybindings for himalaya-email buffer
local bufnr = vim.api.nvim_get_current_buf()
local config = require("himalaya.config")
local keymap_util = require("himalaya.utils.keymap")
local email_mod = require("himalaya.email")
local actions_mod = require("himalaya.actions")

-- Define actions for email reading pane
local actions = {
	close_email = function()
		email_mod.close()
	end,

	reply = function()
		actions_mod.reply()
	end,

	forward = function()
		actions_mod.forward()
	end,

	delete = function()
		actions_mod.delete()
	end,

	move = function()
		actions_mod.move()
	end,

	copy = function()
		actions_mod.copy()
	end,

	download_attachments = function()
		actions_mod.download_attachments()
	end,

	flag_add = function()
		actions_mod.flag_add()
	end,

	flag_remove = function()
		actions_mod.flag_remove()
	end,
}

-- Apply keymaps from config
keymap_util.apply(bufnr, config.config.keymaps.email, actions)

-- Intercept :q, :q!, :quit, and :close to close only the email pane and return to email listing
vim.keymap.set("c", "<CR>", function()
	if vim.fn.getcmdtype() == ":" then
		local cmd = vim.fn.getcmdline():match("^%s*(.-)%s*$")
		if cmd == "q" or cmd == "q!" or cmd == "quit" or cmd == "close" then
			return "<C-u>lua require('himalaya.email').close()<CR>"
		end
	end
	return "<CR>"
end, { expr = true, buffer = bufnr })
