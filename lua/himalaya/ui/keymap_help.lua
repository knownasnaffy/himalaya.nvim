local keymap_util = require("himalaya.utils.keymap")

local M = {}

M.popup = nil

function M.close()
	if M.popup then
		M.popup:unmount()
		M.popup = nil
	end
end

function M.open(title, keymap_config)
	local has_popup, Popup = pcall(require, "nui.popup")
	if not has_popup then
		vim.notify("nui.nvim is required for keymap help", vim.log.levels.ERROR)
		return
	end

	M.close()

	local entries = keymap_util.entries(keymap_config)
	local key_width = 0
	for _, entry in ipairs(entries) do
		key_width = math.max(key_width, vim.fn.strdisplaywidth(entry.key))
	end

	local lines = {}
	local content_width = vim.fn.strdisplaywidth(title)
	for _, entry in ipairs(entries) do
		local padding = string.rep(" ", key_width - vim.fn.strdisplaywidth(entry.key) + 3)
		local line = entry.key .. padding .. entry.desc
		table.insert(lines, line)
		content_width = math.max(content_width, vim.fn.strdisplaywidth(line))
	end

	if #lines == 0 then
		lines = { "No keymaps configured" }
		content_width = math.max(content_width, vim.fn.strdisplaywidth(lines[1]))
	end

	local popup = Popup({
		enter = true,
		focusable = true,
		position = "50%",
		size = {
			width = math.min(math.max(content_width + 2, 30), math.max(vim.o.columns - 4, 1)),
			height = math.min(#lines, math.max(vim.o.lines - 4, 1)),
		},
		border = {
			style = "rounded",
			text = {
				top = " " .. title .. " ",
				top_align = "center",
				bottom = " [q/Esc/g?] Close ",
				bottom_align = "center",
			},
		},
		win_options = {
			wrap = false,
			cursorline = false,
		},
		zindex = 200,
	})

	popup:mount()
	M.popup = popup

	vim.bo[popup.bufnr].modifiable = true
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
	vim.bo[popup.bufnr].modifiable = false
	vim.bo[popup.bufnr].filetype = "himalaya-keymap-help"

	for _, key in ipairs({ "q", "<Esc>", "g?" }) do
		vim.keymap.set("n", key, M.close, {
			buffer = popup.bufnr,
			nowait = true,
			desc = "Close keymap help",
		})
	end
end

return M
