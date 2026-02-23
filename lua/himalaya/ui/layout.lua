local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local state = require("himalaya.state")
local config = require("himalaya.config")
local envelope = require("himalaya.cli.envelope")
local folder = require("himalaya.cli.folder")
local envelope_list = require("himalaya.ui.envelope_list")
local folder_list = require("himalaya.ui.folder_list")

local M = {}

function M.create()
	local sidebar = Popup({
		enter = false,
		focusable = false, -- Disable focus, managed by commands
		border = {
			style = "rounded",
			text = {
				top = " Folders ",
				top_align = "center",
			},
		},
		zindex = 49,
	})

	local main = Popup({
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
			text = {
				top = " Emails ",
				top_align = "center",
			},
		},
		win_options = {
			cursorline = true,
		},
		zindex = 49,
	})

	local layout = Layout(
		{
			position = "50%",
			size = {
				width = "90%",
				height = "90%",
			},
		},
		Layout.Box({
			Layout.Box(sidebar, { size = config.config.sidebar.width }),
			Layout.Box(main, { grow = 1 }),
		}, { dir = "row" })
	)

	-- Mount first to get window dimensions
	layout:mount()

	-- Set filetype for sidebar
	vim.bo[sidebar.bufnr].filetype = "himalaya-folder-listing"

	-- Get window height for main panel
	local main_winid = vim.api.nvim_get_current_win()
	local main_height = vim.api.nvim_win_get_height(main_winid)

	-- Track window close to update state
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(sidebar.winid) .. "," .. tostring(main.winid),
		callback = function()
			state.is_open = false
			state.layout = nil
			state.sidebar = nil
			state.main = nil
		end,
		once = true,
	})

	vim.notify("Loading Himalaya...", vim.log.levels.INFO)

	-- Load folders
	folder.list({}, function(err, data)
		if err then
			vim.notify("Failed to load folders: " .. err, vim.log.levels.ERROR)
			return
		end

		folder_list.render(sidebar.bufnr, data)
	end)

	-- Load envelopes with page_size matching window height
	envelope.list({ page_size = main_height }, function(err, data)
		if err then
			vim.notify("Failed to load emails: " .. err, vim.log.levels.ERROR)
			return
		end

		envelope_list.render(main.bufnr, data)
	end)

	state.layout = layout
	state.sidebar = sidebar.bufnr
	state.main = main.bufnr

	return layout
end

return M
