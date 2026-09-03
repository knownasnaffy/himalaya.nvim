local message_cli = require("himalaya.cli.message")
local runner = require("himalaya.cli.runner")
local fixtures = require("fixtures.v2_fixtures")

describe("CLI Message", function()
	after_each(function()
		runner.reset_mock()
	end)

	it("reads message as plain text", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, fixtures.message_read_text)
		end)

		local content = nil
		message_cli.read({
			id = "14273",
			mailbox = "INBOX",
			seen = true,
		}, function(err, data)
			assert.is_nil(err)
			content = data
		end)

		assert.truthy(executed_cmd)
		local cmd_str = table.concat(executed_cmd, " ")
		assert.contains(cmd_str, "message read")
		assert.contains(cmd_str, "-m INBOX")
		assert.contains(cmd_str, "--seen")
		assert.equals("14273", executed_cmd[#executed_cmd])
		assert.contains(content, "System Alert: All Services Normal")
	end)

	it("copies and moves messages between mailboxes", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, "ok")
		end)

		message_cli.move({
			from = "INBOX",
			to = "Archive",
			ids = { "101", "102" },
		}, function(err)
			assert.is_nil(err)
		end)

		assert.truthy(executed_cmd)
		local has_move = false
		for _, v in ipairs(executed_cmd) do
			if v == "move" then
				has_move = true
			end
		end
		assert.truthy(has_move)
	end)

	it("deletes messages with mailbox target", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, "ok")
		end)

		message_cli.delete({
			mailbox = "INBOX",
			ids = { "101" },
		}, function(err)
			assert.is_nil(err)
		end)

		assert.truthy(executed_cmd)
		local has_delete = false
		for _, v in ipairs(executed_cmd) do
			if v == "delete" then
				has_delete = true
			end
		end
		assert.truthy(has_delete)
	end)
end)
