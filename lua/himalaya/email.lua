local state = require("himalaya.state")
local Layout = require("nui.layout")
local config = require("himalaya.config")

local M = {}

function M.open()
	if not state.layout or not state.main_popup or not state.sidebar_popup or not state.email_popup then
		return
	end

	-- Toggle if already open
	if state.email_visible then
		M.close()
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
