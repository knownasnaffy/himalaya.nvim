local cli = require("himalaya.cli")
local runner = require("himalaya.cli.runner")

describe("CLI Base", function()
	after_each(function()
		runner.reset_mock()
	end)

	it("builds command arguments with global options", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, '{"ok": true}')
		end)

		cli.run_json({ "mailbox", "list" }, function(err, data)
			assert.is_nil(err)
			assert.equals(true, data.ok)
		end, { account = "gmail" })

		assert.truthy(executed_cmd)
		assert.equals("himalaya", executed_cmd[1])
		assert.equals("--json", executed_cmd[2])
		-- Account option should be present
		local has_account = false
		for i, v in ipairs(executed_cmd) do
			if v == "--account" and executed_cmd[i + 1] == "gmail" then
				has_account = true
			end
		end
		assert.truthy(has_account, "expected --account gmail in command")
	end)

	it("parses json and cleans vim.NIL", function()
		runner.set_mock(function(_, callback)
			callback(nil, '{"items": [1, null, 3], "name": null}')
		end)

		cli.run_json({ "test" }, function(err, data)
			assert.is_nil(err)
			assert.is_not_nil(data)
			assert.is_nil(data.name)
		end)
	end)

	it("handles malformed json gracefully", function()
		runner.set_mock(function(_, callback)
			callback(nil, "error: server unreachable")
		end)

		cli.run_json({ "test" }, function(err, data)
			assert.truthy(err)
			assert.contains(err, "Failed to parse JSON")
			assert.is_nil(data)
		end)
	end)
end)
