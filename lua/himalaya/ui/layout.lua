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

local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spinner_index = 1

function M.show_spinner(message)
	if not state.sidebar_popup then
		return
	end

	-- Stop existing timer
	if state.spinner_timer then
		state.spinner_timer:stop()
	end

	-- Start spinner animation
	spinner_index = 1
	state.spinner_timer = vim.loop.new_timer()
	state.spinner_timer:start(
		0,
		80,
		vim.schedule_wrap(function()
			if state.sidebar_popup then
				local frame = spinner_frames[spinner_index]
				state.sidebar_popup.border:set_text("bottom", " " .. frame .. " " .. message .. " ", "center")
				spinner_index = (spinner_index % #spinner_frames) + 1
			end
		end)
	)
end

function M.hide_spinner()
	if state.spinner_timer then
		state.spinner_timer:stop()
		state.spinner_timer = nil
	end

	if state.sidebar_popup then
		state.sidebar_popup.border:set_text("bottom", "", "center")
	end
end

function M.update_page_footer()
	if state.main_popup then
		-- Get window width to calculate padding
		local main_win = vim.fn.bufwinid(state.main)
		if main_win == -1 then
			return
		end
		
		local win_width = vim.api.nvim_win_get_width(main_win)
		local left_text = " Page " .. state.current_page .. " "
		local right_text = " Total: 50 "
		
		-- Calculate padding needed (account for border chars)
		local padding_needed = win_width - vim.fn.strdisplaywidth(left_text) - vim.fn.strdisplaywidth(right_text)
		if padding_needed < 0 then
			padding_needed = 0
		end
		
		local footer_text = left_text .. string.rep(" ", padding_needed) .. right_text
		state.main_popup.border:set_text("bottom", footer_text, "left")
	end
end

function M.create()
	local sidebar = Popup({
		enter = false,
		focusable = false,
		border = {
			style = "rounded",
			text = {
				top = " Folders ",
				top_align = "center",
			},
		},
		win_options = {
			cursorline = true,
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
				bottom = " Page 1 ",
				bottom_align = "center",
			},
		},
		win_options = {
			cursorline = true,
		},
		zindex = 49,
	})

	local email = Popup({
		enter = false,
		focusable = true,
		border = {
			style = "rounded",
			text = {
				top = " Email ",
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
	vim.bo[email.bufnr].filetype = "himalaya-email"

	-- Get window height for main panel
	local main_winid = vim.api.nvim_get_current_win()
	local main_height = vim.api.nvim_win_get_height(main_winid)

	-- Track window close to update state
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(sidebar.winid) .. "," .. tostring(main.winid),
		callback = function()
			if state.spinner_timer then
				state.spinner_timer:stop()
			end
			state.is_open = false
			state.layout = nil
			state.sidebar = nil
			state.main = nil
		end,
		once = true,
	})

	state.layout = layout
	state.sidebar = sidebar.bufnr
	state.sidebar_popup = sidebar
	state.main = main.bufnr
	state.main_popup = main
	state.email = email.bufnr
	state.email_popup = email

	local cache = require("himalaya.cache")

	-- Load folders (use cache if available)
	local cached_folders = cache.get_folders()
	if cached_folders then
		folder_list.render(sidebar.bufnr, cached_folders)
	else
		M.show_spinner("Loading")
		folder.list({}, function(err, data)
			if err then
				M.hide_spinner()
				vim.notify("Failed to load folders: " .. err, vim.log.levels.ERROR)
				return
			end

			cache.set_folders(data)
			folder_list.render(sidebar.bufnr, data)
			M.hide_spinner()
		end)
	end

	-- Load envelopes (use cache if available)
	local cached_envelopes = cache.get_envelopes(state.current_folder, state.current_page)
	if cached_envelopes then
		envelope_list.render(main.bufnr, cached_envelopes)
	else
		M.show_spinner("Loading")
		envelope.list({ page_size = main_height }, function(err, data)
			if err then
				M.hide_spinner()
				vim.notify("Failed to load emails: " .. err, vim.log.levels.ERROR)
				return
			end

			cache.set_envelopes(state.current_folder, state.current_page, data)
			envelope_list.render(main.bufnr, data)
			M.hide_spinner()
		end)
	end

	return layout
end

return M
