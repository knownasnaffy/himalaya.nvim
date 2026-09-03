local account_cli = require("himalaya.cli.account")
local mailbox_cli = require("himalaya.cli.mailbox")
local config = require("himalaya.config")

local M = {}

local function do_select(items, opts, on_choice)
	if config.config.custom_select and type(config.config.custom_select) == "function" then
		config.config.custom_select(items, opts, on_choice)
	else
		vim.ui.select(items, opts, on_choice)
	end
end

function M.select_account(callback)
	account_cli.list({}, function(err, accounts)
		if err then
			vim.notify("Failed to list accounts: " .. tostring(err), vim.log.levels.ERROR)
			return
		end

		if not accounts or #accounts == 0 then
			vim.notify("No accounts found", vim.log.levels.WARN)
			return
		end

		do_select(accounts, {
			prompt = "Select account:",
			format_item = function(item)
				local def = item.default and " (default)" or ""
				local backends = item.backends and table.concat(item.backends, ", ") or ""
				return string.format("%s%s [%s]", item.name, def, backends)
			end,
		}, function(choice)
			if choice then
				callback(choice)
			end
		end)
	end)
end

function M.select_mailbox(callback, account)
	mailbox_cli.list({ account = account }, function(err, mailboxes)
		if err then
			vim.notify("Failed to list mailboxes: " .. tostring(err), vim.log.levels.ERROR)
			return
		end

		if not mailboxes or #mailboxes == 0 then
			vim.notify("No mailboxes found", vim.log.levels.WARN)
			return
		end

		do_select(mailboxes, {
			prompt = "Select mailbox:",
			format_item = function(item)
				local counts = ""
				if item.unread and item.total then
					counts = string.format(" (%d/%d)", item.unread, item.total)
				elseif item.total then
					counts = string.format(" (%d)", item.total)
				end
				return item.name .. counts
			end,
		}, function(choice)
			if choice then
				callback(choice)
			end
		end)
	end)
end

return M
