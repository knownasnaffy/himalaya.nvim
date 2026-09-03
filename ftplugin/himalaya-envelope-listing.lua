-- Keybindings for himalaya-envelope-listing buffer
local bufnr = vim.api.nvim_get_current_buf()
local config = require("himalaya.config")
local keymap_util = require("himalaya.utils.keymap")
local folder_mod = require("himalaya.folder")
local page_mod = require("himalaya.page")
local email_mod = require("himalaya.email")
local himalaya = require("himalaya")
local actions_mod = require("himalaya.actions")
local account_mod = require("himalaya.account")

-- Define actions
local actions = {
	close = function()
		himalaya.close()
	end,

	next_folder = function()
		local count = vim.v.count1
		local start_folder = require("himalaya.state").current_folder

		for _ = 1, count do
			folder_mod.next(true, true)
		end

		local end_folder = require("himalaya.state").current_folder
		if start_folder ~= end_folder then
			folder_mod.reload()
		end
	end,

	previous_folder = function()
		local count = vim.v.count1
		local start_folder = require("himalaya.state").current_folder

		for _ = 1, count do
			folder_mod.previous(true, true)
		end

		local end_folder = require("himalaya.state").current_folder
		if start_folder ~= end_folder then
			folder_mod.reload()
		end
	end,

	folder_picker = function()
		folder_mod.picker()
	end,

	account_picker = function()
		account_mod.select()
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

	compose = function()
		actions_mod.compose()
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

	search = function()
		actions_mod.search()
	end,
}

-- Apply keymaps from config
keymap_util.apply(bufnr, config.config.keymaps.listing, actions)
