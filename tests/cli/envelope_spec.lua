local envelope_cli = require("himalaya.cli.envelope")
local runner = require("himalaya.cli.runner")
local fixtures = require("fixtures.v2_fixtures")

describe("CLI Envelope", function()
	after_each(function()
		runner.reset_mock()
	end)

	it("lists envelopes with -m and pagination and unwraps root object", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, fixtures.envelopes_json)
		end)

		local envelopes = nil
		envelope_cli.list({
			mailbox = "INBOX",
			page = 2,
			page_size = 25,
			has_attachment = true,
			account = "gmail",
		}, function(err, data)
			assert.is_nil(err)
			envelopes = data
		end)

		assert.truthy(executed_cmd)
		-- Check mailbox argument
		local has_mailbox = false
		local has_page = false
		local has_page_size = false
		local has_attach = false
		for i, v in ipairs(executed_cmd) do
			if (v == "-m" or v == "--mailbox") and executed_cmd[i + 1] == "INBOX" then
				has_mailbox = true
			end
			if (v == "-p" or v == "--page") and executed_cmd[i + 1] == "2" then
				has_page = true
			end
			if (v == "-s" or v == "--page-size") and executed_cmd[i + 1] == "25" then
				has_page_size = true
			end
			if v == "--has-attachment" then
				has_attach = true
			end
		end

		assert.truthy(has_mailbox, "expected --mailbox INBOX")
		assert.truthy(has_page, "expected --page 2")
		assert.truthy(has_page_size, "expected --page-size 25")
		assert.truthy(has_attach, "expected --has-attachment")

		assert.is_not_nil(envelopes)
		assert.equals(2, #envelopes)
		assert.equals("14273", envelopes[1].id)
		assert.equals("System Alert: All Services Normal", envelopes[1].subject)
		assert.equals(1, #envelopes[1].from)
		assert.equals("Ops Team", envelopes[1].from[1].name)
		assert.equals("seen", envelopes[1].flags[1].iana)
	end)

	it("supports search query DSL", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, fixtures.envelopes_json)
		end)

		local envelopes = nil
		envelope_cli.search({
			mailbox = "INBOX",
			query = "flag seen and subject Alert",
		}, function(err, data)
			assert.is_nil(err)
			envelopes = data
		end)

		assert.truthy(executed_cmd)
		local has_search = false
		for _, arg in ipairs(executed_cmd) do
			if arg == "search" then
				has_search = true
			end
		end
		assert.truthy(has_search, "expected 'search' in command")
		assert.equals("flag seen and subject Alert", executed_cmd[#executed_cmd])
		assert.is_not_nil(envelopes)
	end)
end)
