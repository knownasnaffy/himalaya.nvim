local state = require("himalaya.state")
local config = require("himalaya.config")
local folder_cli = require("himalaya.cli.folder")
local folder_list = require("himalaya.ui.folder_list")
local envelope = require("himalaya.cli.envelope")
local envelope_list = require("himalaya.ui.envelope_list")
local layout = require("himalaya.ui.layout")

local M = {}

-- Reload emails for current folder
local function reload_emails(silent)
	if not state.main then
		return
	end

	if not silent then
		layout.show_spinner("Loading emails")
	end

	state.current_page = 1
	layout.update_page_footer()

	local cache = require("himalaya.cache")
	local height = vim.api.nvim_win_get_height(vim.api.nvim_get_current_win())
	envelope.list({ folder = state.current_folder, page_size = height }, function(err, data)
		if err then
			layout.hide_spinner()
			vim.notify("Failed to load emails: " .. err, vim.log.levels.ERROR)
			return
		end

		cache.set_envelopes(state.current_folder, state.current_page, data)
		envelope_list.render(state.main, data)
		layout.hide_spinner()
	end)
end

-- Reload folder list to update highlighting
local function reload_folders(silent)
	if not state.sidebar then
		return
	end

	folder_cli.list({}, function(err, data)
		if err then
			if not silent then
				vim.notify("Failed to reload folders: " .. err, vim.log.levels.ERROR)
			end
			return
		end

		folder_list.render(state.sidebar, data)
	end)
end

-- Switch to a folder by name
function M.switch_to(folder_name)
	if not vim.tbl_contains(state.folder_list, folder_name) then
		vim.notify("Folder not found: " .. folder_name, vim.log.levels.ERROR)
		return
	end

	state.current_folder = folder_name
	layout.show_spinner("Switching folder")
	reload_folders(true) -- Silent folder reload
	reload_emails(true) -- Silent email reload (spinner already shown)
end

-- Navigate to next folder
function M.next(silent, skip_reload)
	if #state.folder_list == 0 then
		return
	end

	local current_idx = nil
	for i, name in ipairs(state.folder_list) do
		if name == state.current_folder then
			current_idx = i
			break
		end
	end

	local changed = false
	if not current_idx then
		state.current_folder = state.folder_list[1]
		changed = true
	else
		local next_idx = current_idx + 1
		if next_idx > #state.folder_list then
			if config.config.wrap_folder_navigation then
				next_idx = 1
			else
				-- Clamp to last folder
				next_idx = #state.folder_list
			end
		end

		-- Check if we're moving to a different folder
		if next_idx ~= current_idx then
			state.current_folder = state.folder_list[next_idx]
			changed = true
		end
	end

	-- Only reload if we actually changed folders and not skipping
	if changed and not skip_reload then
		if not silent then
			layout.show_spinner("Switching folder")
		end
		reload_folders(true)
		reload_emails(true)
	elseif not changed and not silent and not skip_reload then
		vim.notify("Already at last folder", vim.log.levels.WARN)
	end
end

-- Navigate to previous folder
function M.previous(silent, skip_reload)
	if #state.folder_list == 0 then
		return
	end

	local current_idx = nil
	for i, name in ipairs(state.folder_list) do
		if name == state.current_folder then
			current_idx = i
			break
		end
	end

	local changed = false
	if not current_idx then
		state.current_folder = state.folder_list[1]
		changed = true
	else
		local prev_idx = current_idx - 1
		if prev_idx < 1 then
			if config.config.wrap_folder_navigation then
				prev_idx = #state.folder_list
			else
				-- Clamp to first folder
				prev_idx = 1
			end
		end

		-- Check if we're moving to a different folder
		if prev_idx ~= current_idx then
			state.current_folder = state.folder_list[prev_idx]
			changed = true
		end
	end

	-- Only reload if we actually changed folders and not skipping
	if changed and not skip_reload then
		if not silent then
			layout.show_spinner("Switching folder")
		end
		reload_folders(true)
		reload_emails(true)
	elseif not changed and not silent and not skip_reload then
		vim.notify("Already at first folder", vim.log.levels.WARN)
	end
end

-- Show folder picker
function M.picker()
	if #state.folder_list == 0 then
		vim.notify("No folders available", vim.log.levels.WARN)
		return
	end

	vim.ui.select(state.folder_list, {
		prompt = "Select folder:",
	}, function(choice)
		if choice then
			M.switch_to(choice)
		end
	end)
end

-- Reload current folder
function M.reload()
	layout.show_spinner("Reloading")

	reload_folders(true)

	-- Reload emails
	if not state.main then
		return
	end

	local height = vim.api.nvim_win_get_height(vim.api.nvim_get_current_win())
	envelope.list({ folder = state.current_folder, page_size = height }, function(err, data)
		if err then
			layout.hide_spinner()
			vim.notify("Failed to load emails: " .. err, vim.log.levels.ERROR)
			return
		end

		envelope_list.render(state.main, data)
		layout.hide_spinner()
	end)
end

return M
