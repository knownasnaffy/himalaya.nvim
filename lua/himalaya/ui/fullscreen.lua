local state = require("himalaya.state")
local config = require("himalaya.config")
local envelope = require("himalaya.cli.envelope")
local folder = require("himalaya.cli.folder")
local envelope_list = require("himalaya.ui.envelope_list")
local folder_list = require("himalaya.ui.folder_list")

local M = {}

function M.create()
	-- Create main buffer for emails
	local main_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[main_buf].filetype = "himalaya-envelope-listing"

	-- Set it in current window
	vim.api.nvim_set_current_buf(main_buf)

	-- Get window dimensions
	local main_win = vim.api.nvim_get_current_win()
	local main_height = vim.api.nvim_win_get_height(main_win)

	-- Disable columns in main window
	vim.wo[main_win].statuscolumn = ""
	vim.wo[main_win].signcolumn = "no"
	vim.wo[main_win].foldcolumn = "0"
	vim.wo[main_win].cursorline = true

	-- Create sidebar split on the left
	vim.cmd("topleft vsplit")
	local sidebar_win = vim.api.nvim_get_current_win()
	local sidebar_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(sidebar_win, sidebar_buf)
	vim.api.nvim_win_set_width(sidebar_win, config.config.sidebar.width)
	vim.bo[sidebar_buf].filetype = "himalaya-folder-listing"

	-- Disable columns in sidebar window
	vim.wo[sidebar_win].statuscolumn = ""
	vim.wo[sidebar_win].signcolumn = "no"
	vim.wo[sidebar_win].foldcolumn = "0"
	vim.wo[sidebar_win].cursorline = true

	-- Switch back to main window
	vim.api.nvim_set_current_win(main_win)

	-- Track state
	state.sidebar = sidebar_buf
	state.main = main_buf

	local cache = require("himalaya.cache")

	local function load_envelopes()
		local cached_envelopes = cache.get_envelopes(state.current_folder, state.current_page)
		if cached_envelopes then
			envelope_list.render(main_buf, cached_envelopes)
		else
			envelope.list({
				mailbox = state.current_folder,
				page = state.current_page,
				page_size = main_height,
				account = state.current_account,
			}, function(err, data)
				if err then
					vim.notify("Failed to load emails: " .. err, vim.log.levels.ERROR)
					return
				end
				cache.set_envelopes(state.current_folder, state.current_page, data)
				envelope_list.render(main_buf, data)
			end)
		end
	end

	local function on_folders_loaded(data)
		cache.set_folders(data)
		folder_list.render(sidebar_buf, data)
		load_envelopes()
	end

	-- Load folders first to resolve active mailbox dynamically (matching himalaya-tui)
	local cached_folders = cache.get_folders()
	if cached_folders then
		on_folders_loaded(cached_folders)
	else
		folder.list({ account = state.current_account }, function(err, data)
			if err then
				vim.notify("Failed to load folders: " .. err, vim.log.levels.ERROR)
				return
			end
			on_folders_loaded(data)
		end)
	end
end

return M
