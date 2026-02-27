local state = require("himalaya.state")
local envelope = require("himalaya.cli.envelope")
local envelope_list = require("himalaya.ui.envelope_list")
local layout = require("himalaya.ui.layout")

local M = {}

function M.next(count)
	count = count or 1
	state.current_page = state.current_page + count
	M.reload()
end

function M.previous(count)
	count = count or 1
	if state.current_page > count then
		state.current_page = state.current_page - count
	else
		state.current_page = 1
	end
	M.reload()
end

function M.reload()
	if not state.main then
		return
	end

	local main_win = vim.fn.bufwinid(state.main)
	if main_win == -1 then
		return
	end

	local main_height = vim.api.nvim_win_get_height(main_win)
	local cache = require("himalaya.cache")

	layout.show_spinner("Loading page " .. state.current_page)

	envelope.list(
		{ folder = state.current_folder, page = state.current_page, page_size = main_height },
		function(err, data)
			if err then
				layout.hide_spinner()
				vim.notify("Failed to load emails: " .. err, vim.log.levels.ERROR)
				return
			end

			cache.set_envelopes(state.current_folder, state.current_page, data)
			envelope_list.render(state.main, data)
			layout.hide_spinner()
			layout.update_page_footer()
		end
	)
end

return M
