local mailbox_cli = require("himalaya.cli.mailbox")
local runner = require("himalaya.cli.runner")
local fixtures = require("fixtures.v2_fixtures")

describe("CLI Mailbox", function()
	after_each(function()
		runner.reset_mock()
	end)

	it("lists mailboxes and unwraps root object", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, fixtures.mailboxes_json)
		end)

		local mailboxes = nil
		mailbox_cli.list({ account = "gmail" }, function(err, data)
			assert.is_nil(err)
			mailboxes = data
		end)

		assert.truthy(executed_cmd)
		local cmd_str = table.concat(executed_cmd, " ")
		assert.truthy(cmd_str:match("mailbox list"), "Command should contain 'mailbox list'")
		assert.truthy(cmd_str:match("%-%-counts"), "Command should include '--counts'")

		assert.is_not_nil(mailboxes)
		assert.equals(3, #mailboxes)
		assert.equals("INBOX", mailboxes[1].id)
		assert.equals("INBOX", mailboxes[1].name)
		assert.equals(42, mailboxes[1].total)
		assert.equals(3, mailboxes[1].unread)
	end)

	it("omits --counts when counts = false is explicitly passed", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, fixtures.mailboxes_json)
		end)

		mailbox_cli.list({ account = "gmail", counts = false }, function() end)

		assert.truthy(executed_cmd)
		local cmd_str = table.concat(executed_cmd, " ")
		assert.truthy(cmd_str:match("mailbox list"))
		assert.falsy(cmd_str:match("%-%-counts"))
	end)
end)
