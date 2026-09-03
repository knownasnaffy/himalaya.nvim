local state = require("himalaya.state")
local flag_cli = require("himalaya.cli.flag")
local message_cli = require("himalaya.cli.message")
local attachment_cli = require("himalaya.cli.attachment")
local envelope_cli = require("himalaya.cli.envelope")
local email_mod = require("himalaya.email")
local envelope_list = require("himalaya.ui.envelope_list")
local picker = require("himalaya.ui.picker")
local composer = require("himalaya.ui.composer")

local M = {}

local function refresh_listing()
	if state.main and vim.api.nvim_buf_is_valid(state.main) then
		envelope_list.render(state.main, state.current_envelopes)
	end
end

function M.add_flag_to_envelope(env, flag, callback)
	if not env or not env.id then
		return
	end

	flag_cli.add({
		mailbox = state.current_folder,
		account = state.current_account,
		flag = flag,
		id = env.id,
	}, function(err)
		if not err then
			table.insert(env.flags, { iana = flag, raw = "\\" .. flag:gsub("^%l", string.upper) })
			refresh_listing()
		end
		if callback then
			callback(err)
		end
	end)
end

function M.remove_flag_from_envelope(env, flag, callback)
	if not env or not env.id then
		return
	end

	flag_cli.remove({
		mailbox = state.current_folder,
		account = state.current_account,
		flag = flag,
		id = env.id,
	}, function(err)
		if not err then
			local new_flags = {}
			for _, f in ipairs(env.flags or {}) do
				local name = type(f) == "table" and (f.iana or f.raw) or f
				if name:lower() ~= flag:lower() then
					table.insert(new_flags, f)
				end
			end
			env.flags = new_flags
			refresh_listing()
		end
		if callback then
			callback(err)
		end
	end)
end

function M.flag_add()
	local env = email_mod.get_selected_envelope()
	if not env then
		vim.notify("No email selected", vim.log.levels.WARN)
		return
	end

	vim.ui.select({ "seen", "flagged", "answered", "draft" }, {
		prompt = "Flag to add:",
	}, function(choice)
		if choice then
			M.add_flag_to_envelope(env, choice, function(err)
				if err then
					vim.notify("Failed to add flag: " .. tostring(err), vim.log.levels.ERROR)
				else
					vim.notify("Added flag " .. choice, vim.log.levels.INFO)
				end
			end)
		end
	end)
end

function M.flag_remove()
	local env = email_mod.get_selected_envelope()
	if not env then
		vim.notify("No email selected", vim.log.levels.WARN)
		return
	end

	vim.ui.select({ "seen", "flagged", "answered", "draft" }, {
		prompt = "Flag to remove:",
	}, function(choice)
		if choice then
			M.remove_flag_from_envelope(env, choice, function(err)
				if err then
					vim.notify("Failed to remove flag: " .. tostring(err), vim.log.levels.ERROR)
				else
					vim.notify("Removed flag " .. choice, vim.log.levels.INFO)
				end
			end)
		end
	end)
end

function M.copy()
	local env = email_mod.get_selected_envelope()
	if not env then
		vim.notify("No email selected", vim.log.levels.WARN)
		return
	end

	picker.select_mailbox(function(target_mbox)
		message_cli.copy({
			from = state.current_folder,
			to = target_mbox.name,
			ids = { env.id },
			account = state.current_account,
		}, function(err)
			if err then
				vim.notify("Failed to copy email: " .. tostring(err), vim.log.levels.ERROR)
			else
				vim.notify(string.format("Copied email %s to %s", env.id, target_mbox.name), vim.log.levels.INFO)
			end
		end)
	end, state.current_account)
end

function M.move()
	local env = email_mod.get_selected_envelope()
	if not env then
		vim.notify("No email selected", vim.log.levels.WARN)
		return
	end

	picker.select_mailbox(function(target_mbox)
		message_cli.move({
			from = state.current_folder,
			to = target_mbox.name,
			ids = { env.id },
			account = state.current_account,
		}, function(err)
			if err then
				vim.notify("Failed to move email: " .. tostring(err), vim.log.levels.ERROR)
			else
				-- Remove from current envelopes view
				local remaining = {}
				for _, item in ipairs(state.current_envelopes or {}) do
					if item.id ~= env.id then
						table.insert(remaining, item)
					end
				end
				state.current_envelopes = remaining
				refresh_listing()
				if state.email_visible and state.selected_email_id == env.id then
					email_mod.close()
				end
				vim.notify(string.format("Moved email %s to %s", env.id, target_mbox.name), vim.log.levels.INFO)
			end
		end)
	end, state.current_account)
end

function M.delete()
	local env = email_mod.get_selected_envelope()
	if not env then
		vim.notify("No email selected", vim.log.levels.WARN)
		return
	end

	local confirm_msg = string.format("Are you sure you want to delete email %s? (y/N): ", env.id)
	vim.ui.input({ prompt = confirm_msg }, function(input)
		if input and input:lower() == "y" then
			message_cli.delete({
				mailbox = state.current_folder,
				ids = { env.id },
				account = state.current_account,
			}, function(err)
				if err then
					vim.notify("Failed to delete email: " .. tostring(err), vim.log.levels.ERROR)
				else
					local remaining = {}
					for _, item in ipairs(state.current_envelopes or {}) do
						if item.id ~= env.id then
							table.insert(remaining, item)
						end
					end
					state.current_envelopes = remaining
					refresh_listing()
					if state.email_visible and state.selected_email_id == env.id then
						email_mod.close()
					end
					vim.notify(string.format("Deleted email %s", env.id), vim.log.levels.INFO)
				end
			end)
		end
	end)
end

function M.download_attachments()
	local env = email_mod.get_selected_envelope()
	if not env then
		vim.notify("No email selected", vim.log.levels.WARN)
		return
	end

	vim.notify("Downloading attachments for email " .. env.id .. "...", vim.log.levels.INFO)
	attachment_cli.download({
		mailbox = state.current_folder,
		id = env.id,
		account = state.current_account,
	}, function(err, out)
		if err then
			vim.notify("Failed to download attachments: " .. tostring(err), vim.log.levels.ERROR)
		else
			vim.notify("Attachments downloaded successfully" .. (out and (": " .. out) or ""), vim.log.levels.INFO)
		end
	end)
end

function M.compose()
	composer.open({ mode = "write" })
end

function M.reply()
	local env = email_mod.get_selected_envelope()
	if not env then
		vim.notify("No email selected", vim.log.levels.WARN)
		return
	end

	local sender = type(env.from) == "table" and (env.from[1] or env.from) or {}
	local to_addr = sender.email or sender.name or ""
	local subj = env.subject or ""
	if not subj:lower():match("^re:") then
		subj = "Re: " .. subj
	end

	composer.open({
		to = to_addr,
		subject = subj,
		mode = "reply",
		id = env.id,
	})
end

function M.forward()
	local env = email_mod.get_selected_envelope()
	if not env then
		vim.notify("No email selected", vim.log.levels.WARN)
		return
	end

	local subj = env.subject or ""
	if not subj:lower():match("^fwd:") then
		subj = "Fwd: " .. subj
	end

	composer.open({
		subject = subj,
		mode = "forward",
		id = env.id,
	})
end

function M.search()
	vim.ui.input({ prompt = "Himalaya search query: " }, function(query)
		if not query or query:match("^%s*$") then
			return
		end

		local layout = require("himalaya.ui.layout")
		layout.show_spinner("Searching")

		envelope_cli.search({
			mailbox = state.current_folder,
			query = query,
			account = state.current_account,
		}, function(err, envelopes)
			layout.hide_spinner()
			if err then
				vim.notify("Search failed: " .. tostring(err), vim.log.levels.ERROR)
				return
			end

			envelope_list.render(state.main, envelopes)
			layout.update_page_footer()
			vim.notify(string.format("Found %d matching emails", #envelopes), vim.log.levels.INFO)
		end)
	end)
end

return M
