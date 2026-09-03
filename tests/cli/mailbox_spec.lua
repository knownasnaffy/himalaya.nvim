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
		assert.equals("mailbox", executed_cmd[#executed_cmd - 1])
		assert.equals("list", executed_cmd[#executed_cmd])

		assert.is_not_nil(mailboxes)
		assert.equals(3, #mailboxes)
		assert.equals("INBOX", mailboxes[1].id)
		assert.equals("INBOX", mailboxes[1].name)
		assert.equals(42, mailboxes[1].total)
		assert.equals(3, mailboxes[1].unread)
	end)
end)
