local state = require("himalaya.state")
local Layout = require("nui.layout")
local config = require("himalaya.config")

local M = {}

function M.open()
	if not state.layout or not state.main_popup or not state.sidebar_popup or not state.email_popup then
		return
	end

	-- If already open, just focus it
	if state.email_visible then
		local email_win = vim.fn.bufwinid(state.email)
		if email_win ~= -1 then
			vim.api.nvim_set_current_win(email_win)
		end
		return
	end

	-- Update layout to show email popup
	state.layout:update(
		Layout.Box({
			Layout.Box(state.sidebar_popup, { size = config.config.sidebar.width }),
			Layout.Box({
				Layout.Box(state.main_popup, { size = "50%" }),
				Layout.Box(state.email_popup, { size = "50%" }),
			}, { dir = "col", grow = 1 }),
		}, { dir = "row" })
	)

	state.email_visible = true

	-- Focus email window
	vim.schedule(function()
		local email_win = vim.fn.bufwinid(state.email)
		if email_win ~= -1 then
			vim.api.nvim_set_current_win(email_win)
		end
	end)

	-- TODO: Load email content
	vim.api.nvim_buf_set_lines(state.email, 0, -1, false, { "Email content will appear here" })
end

function M.close()
	if not state.layout or not state.email_visible then
		return
	end

	-- Update layout to hide email popup
	state.layout:update(
		Layout.Box({
			Layout.Box(state.sidebar_popup, { size = config.config.sidebar.width }),
			Layout.Box(state.main_popup, { grow = 1 }),
		}, { dir = "row" })
	)

	state.email_visible = false
end

return M
