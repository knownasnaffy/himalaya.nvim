local runner = require("himalaya.cli.runner")

describe("CLI Runner", function()
	after_each(function()
		runner.reset_mock()
	end)

	it("uses mock runner when set", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, "mock output")
		end)

		local result = nil
		runner.run({ "himalaya", "--version" }, function(err, stdout)
			assert.is_nil(err)
			result = stdout
		end)

		assert.same({ "himalaya", "--version" }, executed_cmd)
		assert.equals("mock output", result)
	end)

	it("passes errors from runner to callback", function()
		runner.set_mock(function(_, callback)
			callback("command failed", nil)
		end)

		local caught_err = nil
		runner.run({ "himalaya", "bad-command" }, function(err, stdout)
			caught_err = err
			assert.is_nil(stdout)
		end)

		assert.equals("command failed", caught_err)
	end)
end)
