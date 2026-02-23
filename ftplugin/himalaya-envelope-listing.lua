-- Keybindings for himalaya-envelope-listing buffer
local bufnr = vim.api.nvim_get_current_buf()
local config = require("himalaya.config")
local keymap_util = require("himalaya.utils.keymap")
local folder_mod = require("himalaya.folder")
local himalaya = require("himalaya")

-- Define default actions
local actions = {
	close = function()
		himalaya.close()
	end,

	next_folder = function()
		local count = vim.v.count1
		for i = 1, count - 1 do
			folder_mod.next(true, true)
		end
		folder_mod.next(false, false)
	end,

	previous_folder = function()
		local count = vim.v.count1
		for i = 1, count - 1 do
			folder_mod.previous(true, true)
		end
		folder_mod.previous(false, false)
	end,

	folder_picker = function()
		folder_mod.picker()
	end,

	reload = function()
		folder_mod.reload()
	end,
}

-- Apply keymaps from config
keymap_util.apply(bufnr, config.config.keymaps.listing, actions)
