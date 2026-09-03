local NuiLine = require("nui.line")
local folder_utils = require("himalaya.domain.mailbox")
local state = require("himalaya.state")
local config = require("himalaya.config")

local M = {}

local function is_same_folder(name1, name2)
	if not name1 or not name2 then
		return false
	end
	if name1 == name2 then
		return true
	end
	return name1:lower() == name2:lower()
end

-- Recursively render folder tree
local function render_tree(items, lines, depth, active_line)
	depth = depth or 0
	active_line = active_line or { line = 0 }

	for _, item in ipairs(items) do
		local line = NuiLine()
		local indent = string.rep("  ", depth)

		-- Track line number for active folder
		table.insert(lines, line)
		local current_line = #lines

		local is_active = is_same_folder(item.name, state.current_folder)
		if is_active then
			active_line.line = current_line
		end

		-- Folder icon
		local icon = ""
		if config.config.icons_enabled then
			icon = (#item.children > 0) and "\u{e5fe}" or "\u{e5ff}"
		end

		local display = (icon ~= "") and (icon .. " " .. item.displayName) or item.displayName
		local content = " " .. indent .. display

		-- Use different highlight for active/inactive folders and non-selectable nodes
		local highlight = not item.name and "HimalayaFolderDisabled"
			or (is_active and "HimalayaFolderActive" or "HimalayaFolder")
		line:append(content, highlight)

		-- Render unread badge if present
		if item.unread and item.unread > 0 then
			line:append(" (" .. item.unread .. ")", "HimalayaUnread")
		end

		-- Render children recursively
		if #item.children > 0 then
			render_tree(item.children, lines, depth + 1, active_line)
		end
	end

	return active_line.line
end

function M.render(bufnr, folders)
	vim.bo[bufnr].modifiable = true
	vim.bo[bufnr].filetype = "himalaya-folder-listing"

	if folders then
		local cache = require("himalaya.cache")
		if not cache.get_folders() then
			cache.set_folders(folders)
		end
	end

	-- Parse folders into tree structure
	local tree = folder_utils.parse_folders(folders)

	-- Store flat list of accessible folders in state
	state.folder_list = folder_utils.get_accessible_folders(tree)

	-- Select active folder matching himalaya-tui:
	-- 1. If state.current_folder is already set and exists, preserve it (with case normalization)
	-- 2. Otherwise find inbox case-insensitively (position(|m| m.name.eq_ignore_ascii_case("inbox")))
	-- 3. Otherwise fall back to first folder (unwrap_or(0))
	local selected = nil
	if state.current_folder then
		for _, fname in ipairs(state.folder_list) do
			if is_same_folder(fname, state.current_folder) then
				selected = fname
				break
			end
		end
	end

	if not selected then
		for _, fname in ipairs(state.folder_list) do
			if fname:lower() == "inbox" then
				selected = fname
				break
			end
		end
	end

	if not selected and #state.folder_list > 0 then
		selected = state.folder_list[1]
	end

	state.current_folder = selected

	-- Clear buffer first
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

	local lines = {}
	local active_line = { line = 0 }
	render_tree(tree, lines, 0, active_line)

	for i, line in ipairs(lines) do
		line:render(bufnr, -1, i)
	end

	-- Position cursor on active folder line
	if active_line.line > 0 then
		local wins = vim.fn.win_findbuf(bufnr)
		for _, win in ipairs(wins) do
			pcall(vim.api.nvim_win_set_cursor, win, { active_line.line, 0 })
		end
	end

	vim.bo[bufnr].modifiable = false
	vim.bo[bufnr].modified = false
end

return M
