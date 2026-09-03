local actions = require("himalaya.actions")
local state = require("himalaya.state")
local runner = require("himalaya.cli.runner")

describe("Domain Actions", function()
	after_each(function()
		runner.reset_mock()
	end)

	it("toggles flag on selected envelope", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, "ok")
		end)

		state.current_folder = "INBOX"
		state.current_account = "gmail"
		local env = {
			id = "101",
			subject = "Test",
			flags = {},
		}

		actions.add_flag_to_envelope(env, "flagged", function(err)
			assert.is_nil(err)
		end)

		assert.truthy(executed_cmd)
		local cmd_str = table.concat(executed_cmd, " ")
		assert.contains(cmd_str, "flag add")
		assert.contains(cmd_str, "-f flagged")
		assert.contains(cmd_str, "101")
		assert.equals("flagged", env.flags[1].iana)
	end)
end)
