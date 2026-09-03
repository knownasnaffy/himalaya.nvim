local message_cli = require("himalaya.cli.message")
local state = require("himalaya.state")
local config = require("himalaya.config")

local M = {}

M.layout = nil
M.popups = {}
M.previous_win = nil
M.is_closing = false

function M.send_message(data, callback)
	data = data or {}
	message_cli.compose({
		to = data.to,
		cc = data.cc,
		bcc = data.bcc,
		subject = data.subject,
		body = data.body,
		send = true,
		account = data.account or state.current_account,
	}, callback)
end

function M.save_draft(data, callback)
	data = data or {}
	message_cli.compose({
		to = data.to,
		cc = data.cc,
		bcc = data.bcc,
		subject = data.subject,
		body = data.body,
		save = "Drafts",
		account = data.account or state.current_account,
	}, callback)
end

function M.close()
	if M.is_closing then
		return
	end
	M.is_closing = true

	pcall(vim.api.nvim_del_augroup_by_name, "HimalayaComposerClose")

	if M.layout then
		pcall(function()
			M.layout:unmount()
		end)
		M.layout = nil
		M.popups = {}
	end

	local target_win = M.previous_win
	M.previous_win = nil

	local function restore_focus()
		if target_win and vim.api.nvim_win_is_valid(target_win) then
			pcall(vim.api.nvim_set_current_win, target_win)
			return
		end

		if state.email_visible and state.email_popup and state.email_popup.winid and vim.api.nvim_win_is_valid(state.email_popup.winid) then
			pcall(vim.api.nvim_set_current_win, state.email_popup.winid)
		elseif state.main_popup and state.main_popup.winid and vim.api.nvim_win_is_valid(state.main_popup.winid) then
			pcall(vim.api.nvim_set_current_win, state.main_popup.winid)
		elseif state.sidebar_popup and state.sidebar_popup.winid and vim.api.nvim_win_is_valid(state.sidebar_popup.winid) then
			pcall(vim.api.nvim_set_current_win, state.sidebar_popup.winid)
		end
	end

	restore_focus()
	vim.schedule(restore_focus)

	M.is_closing = false
end

function M.open(opts)
	opts = opts or {}

	-- Check for nui dependency
	local has_nui, Layout = pcall(require, "nui.layout")
	local has_popup, Popup = pcall(require, "nui.popup")
	if not has_nui or not has_popup then
		vim.notify("nui.nvim is required for email composer", vim.log.levels.ERROR)
		return
	end

	local current_win = vim.api.nvim_get_current_win()
	local is_composer_win = false
	if M.popups then
		for _, p in pairs(M.popups) do
			if p and p.winid == current_win then
				is_composer_win = true
				break
			end
		end
	end

	-- Close existing composer if open
	M.close()

	if not is_composer_win then
		M.previous_win = current_win
	end

	local border_style = config.get_border_style()

	local to_popup = Popup({
		enter = true,
		focusable = true,
		border = {
			style = border_style,
			text = {
				top = " To ",
				top_align = "left",
			},
		},
		win_options = {
			wrap = false,
		},
	})

	local cc_popup = Popup({
		enter = false,
		focusable = true,
		border = {
			style = border_style,
			text = {
				top = " Cc ",
				top_align = "left",
			},
		},
		win_options = {
			wrap = false,
		},
	})

	local subject_popup = Popup({
		enter = false,
		focusable = true,
		border = {
			style = border_style,
			text = {
				top = " Subject ",
				top_align = "left",
			},
		},
		win_options = {
			wrap = false,
		},
	})

	local body_popup = Popup({
		enter = false,
		focusable = true,
		border = {
			style = border_style,
			text = {
				top = " Body ",
				top_align = "left",
				bottom = " [<C-s>] Send  [<C-d>] Draft  [<Esc>] Cancel  [<Tab>] Next Field ",
				bottom_align = "center",
			},
		},
	})

	local layout = Layout(
		{
			position = "50%",
			size = {
				width = "90%",
				height = "90%",
			},
		},
		Layout.Box({
			Layout.Box({
				Layout.Box(to_popup, { size = "50%" }),
				Layout.Box(cc_popup, { size = "50%" }),
			}, { dir = "row", size = 3 }),
			Layout.Box(subject_popup, { size = 3 }),
			Layout.Box(body_popup, { grow = 1 }),
		}, { dir = "col" })
	)

	layout:mount()
	M.layout = layout
	M.popups = {
		to = to_popup,
		cc = cc_popup,
		subject = subject_popup,
		body = body_popup,
	}

	-- Pre-populate fields
	if opts.to then
		local to_str = type(opts.to) == "table" and table.concat(opts.to, ", ") or opts.to
		vim.api.nvim_buf_set_lines(to_popup.bufnr, 0, -1, false, { to_str })
	end

	if opts.cc then
		local cc_str = type(opts.cc) == "table" and table.concat(opts.cc, ", ") or opts.cc
		vim.api.nvim_buf_set_lines(cc_popup.bufnr, 0, -1, false, { cc_str })
	end

	if opts.subject then
		vim.api.nvim_buf_set_lines(subject_popup.bufnr, 0, -1, false, { opts.subject })
	end

	if opts.body then
		local body_lines
		if type(opts.body) == "table" then
			body_lines = opts.body
		else
			local body_str = (opts.body or ""):gsub("\r\n", "\n"):gsub("\r", "")
			if body_str:sub(-1) == "\n" then
				body_str = body_str:sub(1, -2)
			end
			body_lines = vim.split(body_str, "\n", { plain = true })
		end
		vim.api.nvim_buf_set_lines(body_popup.bufnr, 0, -1, false, body_lines)
	end

	vim.bo[body_popup.bufnr].filetype = "mail"

	-- Collect current data from buffers
	local function get_form_data()
		local to_lines = vim.api.nvim_buf_get_lines(to_popup.bufnr, 0, -1, false)
		local cc_lines = vim.api.nvim_buf_get_lines(cc_popup.bufnr, 0, -1, false)
		local subj_lines = vim.api.nvim_buf_get_lines(subject_popup.bufnr, 0, -1, false)
		local body_lines = vim.api.nvim_buf_get_lines(body_popup.bufnr, 0, -1, false)

		local to = table.concat(to_lines, " "):gsub("^%s+", ""):gsub("%s+$", "")
		local cc = table.concat(cc_lines, " "):gsub("^%s+", ""):gsub("%s+$", "")
		local subject = table.concat(subj_lines, " "):gsub("^%s+", ""):gsub("%s+$", "")
		local body = table.concat(body_lines, "\n")

		return {
			to = to ~= "" and to or nil,
			cc = cc ~= "" and cc or nil,
			subject = subject ~= "" and subject or nil,
			body = body,
			account = state.current_account,
		}
	end

	-- Keybindings across all popup windows
	local order = { to_popup, cc_popup, subject_popup, body_popup }

	for idx, popup in ipairs(order) do
		local next_popup = order[idx % #order + 1]
		local prev_idx = idx - 1 == 0 and #order or (idx - 1)
		local prev_popup = order[prev_idx]

		-- Tab cycles forward, S-Tab cycles backward
		vim.keymap.set({ "n", "i" }, "<Tab>", function()
			vim.api.nvim_set_current_win(next_popup.winid)
		end, { buffer = popup.bufnr, nowait = true })

		vim.keymap.set({ "n", "i" }, "<S-Tab>", function()
			vim.api.nvim_set_current_win(prev_popup.winid)
		end, { buffer = popup.bufnr, nowait = true })

		-- <C-s> to send
		vim.keymap.set({ "n", "i" }, "<C-s>", function()
			local form = get_form_data()
			if not form.to then
				vim.notify("Recipient (To) is required", vim.log.levels.WARN)
				return
			end
			vim.notify("Sending email...", vim.log.levels.INFO)
			M.send_message(form, function(err)
				if err then
					vim.notify("Failed to send email: " .. tostring(err), vim.log.levels.ERROR)
				else
					vim.notify("Email sent successfully", vim.log.levels.INFO)
					M.close()
				end
			end)
		end, { buffer = popup.bufnr, nowait = true })

		-- <C-d> to save draft
		vim.keymap.set({ "n", "i" }, "<C-d>", function()
			local form = get_form_data()
			vim.notify("Saving draft...", vim.log.levels.INFO)
			M.save_draft(form, function(err)
				if err then
					vim.notify("Failed to save draft: " .. tostring(err), vim.log.levels.ERROR)
				else
					vim.notify("Draft saved to Drafts", vim.log.levels.INFO)
					M.close()
				end
			end)
		end, { buffer = popup.bufnr, nowait = true })

		-- <Esc> in normal mode closes composer
		vim.keymap.set("n", "<Esc>", function()
			M.close()
		end, { buffer = popup.bufnr, nowait = true })

		-- Intercept :q, :q!, :quit, and :close in command line to close composer cleanly
		vim.keymap.set("c", "<CR>", function()
			if vim.fn.getcmdtype() == ":" then
				local cmd = vim.fn.getcmdline():match("^%s*(.-)%s*$")
				if cmd == "q" or cmd == "q!" or cmd == "quit" or cmd == "close" then
					return "<C-u>lua require('himalaya.ui.composer').close()<CR>"
				end
			end
			return "<CR>"
		end, { expr = true, buffer = popup.bufnr })
	end

	-- Track popup window close events to ensure clean composer teardown
	local win_ids = {}
	for _, popup in ipairs(order) do
		if popup.winid then
			table.insert(win_ids, tostring(popup.winid))
		end
	end

	if #win_ids > 0 then
		local group = vim.api.nvim_create_augroup("HimalayaComposerClose", { clear = true })
		vim.api.nvim_create_autocmd("WinClosed", {
			group = group,
			pattern = table.concat(win_ids, ","),
			callback = function()
				if not M.is_closing then
					M.close()
				end
			end,
			once = true,
		})
	end

	-- Focus initial window
	if to_popup.winid and vim.api.nvim_win_is_valid(to_popup.winid) then
		pcall(vim.api.nvim_set_current_win, to_popup.winid)
	end
	vim.schedule(function()
		if to_popup.winid and vim.api.nvim_win_is_valid(to_popup.winid) then
			pcall(vim.api.nvim_set_current_win, to_popup.winid)
		end
	end)
end

return M
