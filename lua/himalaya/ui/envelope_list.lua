local NuiLine = require("nui.line")
local date_utils = require("himalaya.utils.date")
local state = require("himalaya.state")

local M = {}

local function has_flag(flags, target)
	if not flags then
		return false
	end
	target = target:lower()
	for _, f in ipairs(flags) do
		if type(f) == "table" then
			if f.iana and f.iana:lower() == target then
				return true
			end
			if f.raw and f.raw:lower():find(target, 1, true) then
				return true
			end
		elseif type(f) == "string" then
			if f:lower() == target or f:lower():find(target, 1, true) then
				return true
			end
		end
	end
	return false
end

function M.render(bufnr, envelopes)
	vim.bo[bufnr].modifiable = true
	vim.bo[bufnr].filetype = "himalaya-envelope-listing"

	state.current_envelopes = envelopes or {}

	-- Handle empty envelope list
	if not envelopes or #envelopes == 0 then
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "No emails in this mailbox" })
		vim.bo[bufnr].modifiable = false
		vim.bo[bufnr].modified = false
		state.current_envelope_count = 0
		return
	end

	-- Track envelope count
	state.current_envelope_count = #envelopes

	-- Use fixed max date width
	local max_date_width = date_utils.max_date_width()

	-- Get window width for subject calculation (fallback to 80 if headless)
	local win_width = 80
	local ok, width = pcall(vim.api.nvim_win_get_width, 0)
	if ok and width and width > 40 then
		win_width = width
	end

	local subject_width = win_width - 2 - 25 - max_date_width - 7
	if subject_width < 10 then
		subject_width = 10
	end

	-- Clear buffer first
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

	local lines = {}

	for _, env in ipairs(envelopes) do
		local line = NuiLine()

		-- Flag indicator
		local is_seen = has_flag(env.flags, "seen")
		local is_flagged = has_flag(env.flags, "flagged")

		local flag_symbol = " "
		local flag_hl = "HimalayaFlag"

		if is_flagged then
			flag_symbol = "★"
			flag_hl = "HimalayaFlagged"
		elseif not is_seen then
			flag_symbol = "●"
			flag_hl = "HimalayaUnread"
		end
		line:append(flag_symbol .. " ", flag_hl)

		-- Attachment indicator
		local has_attachment = env["has-attachment"] or env.has_attachment
		if has_attachment then
			line:append("@ ", "HimalayaAttachment")
		else
			line:append("  ", "HimalayaAttachment")
		end

		-- From - handle v2 array of Address objects or fallback
		local from = "Unknown"
		if env.from then
			local sender = type(env.from) == "table" and (env.from[1] or env.from) or {}
			from = sender.name or sender.email or sender.addr or "Unknown"
		end
		local from_display = from:sub(1, 23)
		local from_padding = 23 - vim.fn.strdisplaywidth(from_display)
		if from_padding < 0 then
			from_padding = 0
		end
		line:append(from_display .. string.rep(" ", from_padding) .. " ", "HimalayaFrom")

		-- Subject - truncate based on display width
		local subject = env.subject or "(no subject)"
		local subject_display = subject
		local truncated = false

		while vim.fn.strdisplaywidth(subject_display) > subject_width do
			subject_display = subject_display:sub(1, #subject_display - 1)
			truncated = true
		end

		if truncated then
			while vim.fn.strdisplaywidth(subject_display .. "...") > subject_width do
				subject_display = subject_display:sub(1, #subject_display - 1)
			end
			subject_display = subject_display .. "..."
		end

		local padding = subject_width + 1 - vim.fn.strdisplaywidth(subject_display)
		if padding < 0 then
			padding = 0
		end
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
