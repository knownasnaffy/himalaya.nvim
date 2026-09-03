local flag_cli = require("himalaya.cli.flag")
local runner = require("himalaya.cli.runner")

describe("CLI Flag", function()
	after_each(function()
		runner.reset_mock()
	end)

	it("adds flags to messages", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, "ok")
		end)

		flag_cli.add({
			mailbox = "INBOX",
			flag = "seen",
			ids = { "101", "102" },
		}, function(err)
			assert.is_nil(err)
		end)

		assert.truthy(executed_cmd)
		local cmd_str = table.concat(executed_cmd, " ")
		assert.contains(cmd_str, "flag add")
		assert.contains(cmd_str, "-m INBOX")
		assert.contains(cmd_str, "-f seen")
		assert.contains(cmd_str, "101 102")
	end)

	it("removes flags from messages", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, "ok")
		end)

		flag_cli.remove({
			mailbox = "INBOX",
			flag = "flagged",
			id = "101",
		}, function(err)
			assert.is_nil(err)
		end)

		assert.truthy(executed_cmd)
		local cmd_str = table.concat(executed_cmd, " ")
		assert.contains(cmd_str, "flag remove")
		assert.contains(cmd_str, "-f flagged")
		assert.contains(cmd_str, "101")
	end)
end)
