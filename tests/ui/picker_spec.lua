local picker = require("himalaya.ui.picker")
local account_cli = require("himalaya.cli.account")
local mailbox_cli = require("himalaya.cli.mailbox")
local runner = require("himalaya.cli.runner")
local fixtures = require("fixtures.v2_fixtures")

describe("UI Picker", function()
	after_each(function()
		runner.reset_mock()
	end)

	it("selects account via vim.ui.select", function()
		runner.set_mock(function(cmd, callback)
			callback(nil, fixtures.accounts_json)
		end)

		local old_select = vim.ui.select
		vim.ui.select = function(items, opts, on_choice)
			assert.equals("Select account:", opts.prompt)
			assert.equals(2, #items)
			on_choice(items[2]) -- select "work"
		end

		local chosen = nil
		picker.select_account(function(account)
			chosen = account
		end)

		assert.is_not_nil(chosen)
		assert.equals("work", chosen.name)

		vim.ui.select = old_select
	end)

	it("selects mailbox via vim.ui.select", function()
		runner.set_mock(function(cmd, callback)
			callback(nil, fixtures.mailboxes_json)
		end)

		local old_select = vim.ui.select
		vim.ui.select = function(items, opts, on_choice)
			assert.equals("Select mailbox:", opts.prompt)
			assert.equals(3, #items)
			on_choice(items[1]) -- select "INBOX"
		end

		local chosen = nil
		picker.select_mailbox(function(mbox)
			chosen = mbox
		end)

		assert.is_not_nil(chosen)
		assert.equals("INBOX", chosen.name)

		vim.ui.select = old_select
	end)
end)
