vim.api.nvim_create_user_command("Himalaya", function(opts)
	local account = opts.args
	if account and account ~= "" then
		require("himalaya.state").current_account = account
	end
	require("himalaya").open()
end, {
	nargs = "?",
	complete = function(arg_lead)
		local ok, account_cli = pcall(require, "himalaya.cli.account")
		if not ok then
			return {}
		end
		local accounts = {}
		account_cli.list({}, function(_, data)
			for _, acc in ipairs(data or {}) do
				if vim.startswith(acc.name, arg_lead) then
					table.insert(accounts, acc.name)
				end
			end
		end)
		return accounts
	end,
})

local function mailbox_handler(opts)
	local arg = opts.args
	local folder_nav = require("himalaya.folder")

	if arg == "next" then
		folder_nav.next()
	elseif arg == "previous" then
		folder_nav.previous()
	else
		folder_nav.switch_to(arg)
	end
end

local mailbox_complete = function(arg_lead)
	local state = require("himalaya.state")
	local completions = { "next", "previous" }
	vim.list_extend(completions, state.folder_list)
	return vim.tbl_filter(function(item)
		return vim.startswith(item, arg_lead)
	end, completions)
end

vim.api.nvim_create_user_command("HimalayaMailbox", mailbox_handler, {
	nargs = 1,
	complete = mailbox_complete,
})

vim.api.nvim_create_user_command("HimalayaFolder", mailbox_handler, {
	nargs = 1,
	complete = mailbox_complete,
})

vim.api.nvim_create_user_command("HimalayaMailboxes", function()
	require("himalaya.folder").picker()
end, {})

vim.api.nvim_create_user_command("HimalayaFolders", function()
	require("himalaya.folder").picker()
end, {})

vim.api.nvim_create_user_command("HimalayaAccounts", function()
	require("himalaya.account").select()
end, {})

vim.api.nvim_create_user_command("HimalayaAccount", function(opts)
	require("himalaya.account").switch_to(opts.args)
end, {
	nargs = 1,
	complete = function(arg_lead)
		local ok, account_cli = pcall(require, "himalaya.cli.account")
		if not ok then
			return {}
		end
		local accounts = {}
		account_cli.list({}, function(_, data)
			for _, acc in ipairs(data or {}) do
				if vim.startswith(acc.name, arg_lead) then
					table.insert(accounts, acc.name)
				end
			end
		end)
		return accounts
	end,
})

vim.api.nvim_create_user_command("HimalayaWrite", function()
	require("himalaya.actions").compose()
end, {})

vim.api.nvim_create_user_command("HimalayaSearch", function()
	require("himalaya.actions").search()
end, {})
