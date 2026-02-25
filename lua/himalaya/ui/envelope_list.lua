local NuiLine = require("nui.line")
local date_utils = require("himalaya.utils.date")

local M = {}

function M.render(bufnr, envelopes)
	vim.bo[bufnr].modifiable = true
	vim.bo[bufnr].filetype = "himalaya-envelope-listing"

	-- Handle empty envelope list
	if not envelopes or #envelopes == 0 then
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "No emails in this folder" })
		vim.bo[bufnr].modifiable = false
		vim.bo[bufnr].modified = false
		return
	end

	-- Use fixed max date width
	local max_date_width = date_utils.max_date_width()

	-- Get buffer width for subject calculation
	local bufwidth = vim.api.nvim_win_get_width(0)
	local subject_width = bufwidth - 2 - 25 - max_date_width - 7 -- flag + from + date + spacing + parens + extra space

	-- Clear buffer first
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

	local lines = {}

	for _, env in ipairs(envelopes) do
		local line = NuiLine()

		-- Flag indicator
		local flag = " "
		if vim.tbl_contains(env.flags or {}, "Seen") then
			flag = " "
		else
			flag = "●"
		end
		line:append(flag .. " ", "HimalayaFlag")

		-- From - handle nil values safely
		local from = "Unknown"
		if env.from then
			from = env.from.name or env.from.addr or "Unknown"
		end
		local from_display = from:sub(1, 25)
		local from_padding = 25 - vim.fn.strdisplaywidth(from_display)
		line:append(from_display .. string.rep(" ", from_padding) .. " ", "HimalayaFrom")

		-- Subject - truncate based on display width
		local subject = env.subject or "(no subject)"
		local subject_display = subject
		local truncated = false

		-- Truncate to fit display width
		while vim.fn.strdisplaywidth(subject_display) > subject_width do
			subject_display = subject_display:sub(1, #subject_display - 1)
			truncated = true
		end

		if truncated then
			-- Remove extra chars to make room for "..."
			while vim.fn.strdisplaywidth(subject_display .. "...") > subject_width do
				subject_display = subject_display:sub(1, #subject_display - 1)
			end
			subject_display = subject_display .. "..."
		end

		-- Pad subject to fixed width + 1 space
		local padding = subject_width + 1 - vim.fn.strdisplaywidth(subject_display)
		line:append(subject_display .. string.rep(" ", padding), "HimalayaSubject")

		-- Date (relative)
		local relative = date_utils.relative_date(env.date)
		line:append("(" .. relative .. ")", "HimalayaDate")

		table.insert(lines, line)
	end

	for i, line in ipairs(lines) do
		line:render(bufnr, -1, i)
	end

	vim.bo[bufnr].modifiable = false
	vim.bo[bufnr].modified = false
end

return M
