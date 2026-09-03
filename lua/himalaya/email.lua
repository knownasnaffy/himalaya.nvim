local state = require("himalaya.state")
local Layout = require("nui.layout")
local config = require("himalaya.config")
local message_cli = require("himalaya.cli.message")

local M = {}

function M.get_selected_envelope()
	if not state.main or not state.current_envelopes then
		return nil
	end

	local win = vim.fn.bufwinid(state.main)
	local linenr = 1
	if win ~= -1 then
		linenr = vim.api.nvim_win_get_cursor(win)[1]
	end

	return state.current_envelopes[linenr]
end

function M.open()
	if not state.layout or not state.main_popup or not state.sidebar_popup or not state.email_popup then
		return
	end

	local env = M.get_selected_envelope()
	if not env or not env.id then
		return
	end

	state.selected_email_id = env.id

	-- If already open, just focus it
	local email_win_valid = state.email_popup.winid and vim.api.nvim_win_is_valid(state.email_popup.winid)
	if not state.email_visible or not email_win_valid then
		state.layout:update(Layout.Box({
			Layout.Box(state.sidebar_popup, { size = config.config.sidebar.width }),
			Layout.Box({
				Layout.Box(state.main_popup, { size = "50%" }),
				Layout.Box(state.email_popup, { grow = 1 }),
			}, { dir = "col", grow = 1 }),
		}, { dir = "row" }))
		state.email_visible = true
	end

	-- Focus email window
	vim.schedule(function()
		if state.email and vim.api.nvim_buf_is_valid(state.email) then
			local email_win = vim.fn.bufwinid(state.email)
			if email_win ~= -1 then
				vim.api.nvim_set_current_win(email_win)
			end
		end
	end)

	vim.bo[state.email].modifiable = true
	vim.api.nvim_buf_set_lines(state.email, 0, -1, false, { "Loading email " .. env.id .. "..." })

	message_cli.read({
		id = env.id,
		mailbox = state.current_folder,
		account = state.current_account,
		seen = true,
	}, function(err, content)
		if not state.email or not vim.api.nvim_buf_is_valid(state.email) then
			return
		end

		vim.bo[state.email].modifiable = true
		if err then
			vim.api.nvim_buf_set_lines(state.email, 0, -1, false, { "Error loading email: " .. tostring(err) })
		else
			local clean_content = (content or ""):gsub("\r\n", "\n"):gsub("\r", "")
			if clean_content:sub(-1) == "\n" then
				clean_content = clean_content:sub(1, -2)
			end
			local lines = vim.split(clean_content, "\n", { plain = true })
			vim.api.nvim_buf_set_lines(state.email, 0, -1, false, lines)

			-- Mark seen in current envelopes cache and refresh row flag
			local has_seen = false
			for _, f in ipairs(env.flags or {}) do
				if (type(f) == "table" and f.iana == "seen") or f == "seen" then
					has_seen = true
					break
				end
			end
			if not has_seen then
				table.insert(env.flags, { iana = "seen", raw = "\\Seen" })
				local envelope_list = require("himalaya.ui.envelope_list")
				envelope_list.render(state.main, state.current_envelopes)
			end
		end

		vim.bo[state.email].modifiable = false
		vim.bo[state.email].modified = false
		vim.bo[state.email].filetype = "himalaya-email"
	end)
end

function M.close()
	if not state.layout or not state.email_visible then
		return
	end

	-- Update layout to hide email popup
	state.layout:update(Layout.Box({
		Layout.Box(state.sidebar_popup, { size = config.config.sidebar.width }),
		Layout.Box(state.main_popup, { grow = 1 }),
	}, { dir = "row" }))

	state.email_visible = false

	-- Realign main window content to fill the space
	vim.schedule(function()
		if state.main and vim.api.nvim_buf_is_valid(state.main) then
			local main_win = vim.fn.bufwinid(state.main)
			if main_win ~= -1 then
				vim.api.nvim_set_current_win(main_win)
				local cursor = vim.api.nvim_win_get_cursor(main_win)
				vim.cmd("normal! gg")
				vim.api.nvim_win_set_cursor(main_win, cursor)
			end
		end
	end)
end

return M
