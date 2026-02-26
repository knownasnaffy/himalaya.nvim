-- Keybindings for himalaya-envelope-listing buffer
local bufnr = vim.api.nvim_get_current_buf()
local config = require("himalaya.config")
local keymap_util = require("himalaya.utils.keymap")
local folder_mod = require("himalaya.folder")
local page_mod = require("himalaya.page")
local email_mod = require("himalaya.email")
local himalaya = require("himalaya")

-- Define default actions
local actions = {
	close = function()
		himalaya.close()
	end,

	next_folder = function()
		local count = vim.v.count1
		local start_folder = require("himalaya.state").current_folder

		for i = 1, count do
			folder_mod.next(true, true)
		end

		-- Check if we actually moved
		local end_folder = require("himalaya.state").current_folder
		if start_folder ~= end_folder then
			-- Force reload after all navigation
			folder_mod.reload()
		end
	end,

	previous_folder = function()
		local count = vim.v.count1
		local start_folder = require("himalaya.state").current_folder

		for i = 1, count do
			folder_mod.previous(true, true)
		end

		-- Check if we actually moved
		local end_folder = require("himalaya.state").current_folder
		if start_folder ~= end_folder then
			-- Force reload after all navigation
			folder_mod.reload()
		end
	end,

	folder_picker = function()
		folder_mod.picker()
	end,

	reload = function()
		folder_mod.reload()
	end,

	next_page = function()
		page_mod.next(vim.v.count1)
	end,

	previous_page = function()
		page_mod.previous(vim.v.count1)
	end,

	open_email = function()
		email_mod.open()
	end,
}

-- Apply keymaps from config
keymap_util.apply(bufnr, config.config.keymaps.listing, actions)
