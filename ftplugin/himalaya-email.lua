-- Keybindings for himalaya-email buffer
local bufnr = vim.api.nvim_get_current_buf()
local config = require("himalaya.config")
local keymap_util = require("himalaya.utils.keymap")
local email_mod = require("himalaya.email")

-- Define default actions
local actions = {
	close_email = function()
		email_mod.close()
	end,
}

-- Apply keymaps from config
keymap_util.apply(bufnr, config.config.keymaps.email, actions)
