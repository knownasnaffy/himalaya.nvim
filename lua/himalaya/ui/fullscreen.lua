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
	vim.wo[main_win].statuscolumn = ''
	vim.wo[main_win].signcolumn = 'no'
	vim.wo[main_win].foldcolumn = '0'
	vim.wo[main_win].cursorline = true
	
	-- Create sidebar split on the left
	vim.cmd("topleft vsplit")
	local sidebar_win = vim.api.nvim_get_current_win()
	local sidebar_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(sidebar_win, sidebar_buf)
	vim.api.nvim_win_set_width(sidebar_win, config.config.sidebar.width)
	vim.bo[sidebar_buf].filetype = "himalaya-folder-listing"
	
	-- Disable columns in sidebar window
	vim.wo[sidebar_win].statuscolumn = ''
	vim.wo[sidebar_win].signcolumn = 'no'
	vim.wo[sidebar_win].foldcolumn = '0'
	vim.wo[sidebar_win].cursorline = true
	
	-- Switch back to main window
	vim.api.nvim_set_current_win(main_win)
	
	-- Track state
	state.sidebar = sidebar_buf
	state.main = main_buf
	
	-- Load folders
	folder.list({}, function(err, data)
		if err then
			vim.notify("Failed to load folders: " .. err, vim.log.levels.ERROR)
			return
		end
		folder_list.render(sidebar_buf, data)
	end)
	
	-- Load envelopes
	envelope.list({ page_size = main_height }, function(err, data)
		if err then
			vim.notify("Failed to load emails: " .. err, vim.log.levels.ERROR)
			return
		end
		envelope_list.render(main_buf, data)
	end)
end

return M
