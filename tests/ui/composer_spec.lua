local composer = require("himalaya.ui.composer")
local runner = require("himalaya.cli.runner")

describe("UI Composer", function()
	after_each(function()
		runner.reset_mock()
	end)

	it("extracts composition data and builds compose arguments", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, "ok")
		end)

		composer.send_message({
			to = "recipient@example.com",
			cc = "copy@example.com",
			subject = "Testing Himalaya v2",
			body = "Hello from Neovim!",
			account = "gmail",
		}, function(err)
			assert.is_nil(err)
		end)

		assert.truthy(executed_cmd)
		local cmd_str = table.concat(executed_cmd, " ")
		assert.contains(cmd_str, "message compose")
		assert.contains(cmd_str, "-t recipient@example.com")
		assert.contains(cmd_str, "--cc copy@example.com")
		assert.contains(cmd_str, "-s Testing Himalaya v2")
		assert.contains(cmd_str, "--send")
	end)

	it("saves draft with --save", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, "ok")
		end)

		composer.save_draft({
			to = "recipient@example.com",
			subject = "Draft Subject",
			body = "Draft Body",
			account = "gmail",
		}, function(err)
			assert.is_nil(err)
		end)

		assert.truthy(executed_cmd)
		local cmd_str = table.concat(executed_cmd, " ")
		assert.contains(cmd_str, "message compose")
		assert.contains(cmd_str, "--save Drafts")
	end)
end)
