local NuiLine = require("nui.line")
local folder_utils = require("himalaya.utils.folder")
local state = require("himalaya.state")
local config = require("himalaya.config")

local M = {}

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

		if item.name and item.name == state.current_folder then
			active_line.line = current_line
		end

		-- Folder icon
		local icon = ""
		if config.config.icons_enabled then
			icon = (#item.children > 0) and "" or ""
		end

		-- Add space after icon if present, and horizontal padding
		local display = icon ~= "" and (icon .. " " .. item.displayName) or item.displayName
		local content = " " .. indent .. display

		line:append(content, "HimalayaFolder")

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

	-- Parse folders into tree structure
	local tree = folder_utils.parse_folders(folders)

	-- Store flat list of accessible folders in state
	state.folder_list = folder_utils.get_accessible_folders(tree)

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
			vim.api.nvim_win_set_cursor(win, { active_line.line, 0 })
		end
	end

	vim.bo[bufnr].modifiable = false
	vim.bo[bufnr].modified = false
end

return M
