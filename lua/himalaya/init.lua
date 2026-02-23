local config = require("himalaya.config")
local layout = require("himalaya.ui.layout")
local state = require("himalaya.state")

local M = {}

function M.setup(opts)
	config.setup(opts)
end

function M.open()
	-- Check if already open
	if state.is_open then
		vim.notify("Himalaya is already open", vim.log.levels.WARN)
		return
	end

	local l = layout.create()
	l:mount()
	state.is_open = true
end

function M.close()
	if state.layout then
		state.layout:unmount()
		state.layout = nil
		state.sidebar = nil
		state.main = nil
		state.is_open = false
	end
end

return M
