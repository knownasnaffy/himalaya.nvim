local account_cli = require("himalaya.cli.account")
local runner = require("himalaya.cli.runner")
local fixtures = require("fixtures.v2_fixtures")

describe("CLI Account", function()
	after_each(function()
		runner.reset_mock()
	end)

	it("lists accounts and unwraps root object", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, fixtures.accounts_json)
		end)

		local accounts = nil
		account_cli.list({}, function(err, data)
			assert.is_nil(err)
			accounts = data
		end)

		assert.truthy(executed_cmd)
		assert.equals("account", executed_cmd[#executed_cmd - 1])
		assert.equals("list", executed_cmd[#executed_cmd])

		assert.is_not_nil(accounts)
		assert.equals(2, #accounts)
		assert.equals("gmail", accounts[1].name)
		assert.equals(true, accounts[1].default)
		assert.same({ "imap", "smtp" }, accounts[1].backends)
	end)
end)
