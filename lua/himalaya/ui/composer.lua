local message_cli = require("himalaya.cli.message")
local state = require("himalaya.state")

local M = {}

M.layout = nil
M.popups = {}

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
	if M.layout then
		M.layout:unmount()
		M.layout = nil
		M.popups = {}
	end
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

	-- Close existing composer if open
	M.close()

	local to_popup = Popup({
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
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
			style = "rounded",
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
			style = "rounded",
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
			style = "rounded",
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
		local body_lines = type(opts.body) == "table" and opts.body or vim.split(opts.body, "\n", { plain = true })
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
	end

	-- Focus initial window
	vim.schedule(function()
		if to_popup.winid and vim.api.nvim_win_is_valid(to_popup.winid) then
			vim.api.nvim_set_current_win(to_popup.winid)
		end
	end)
end

return M
