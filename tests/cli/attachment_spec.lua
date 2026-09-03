local attachment_cli = require("himalaya.cli.attachment")
local runner = require("himalaya.cli.runner")

describe("CLI Attachment", function()
	after_each(function()
		runner.reset_mock()
	end)

	it("downloads attachments with destination directory", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, "ok")
		end)

		attachment_cli.download({
			mailbox = "INBOX",
			id = "14273",
			dir = "/tmp/downloads",
		}, function(err)
			assert.is_nil(err)
		end)

		assert.truthy(executed_cmd)
		local cmd_str = table.concat(executed_cmd, " ")
		assert.contains(cmd_str, "attachment download")
		assert.contains(cmd_str, "-m INBOX")
		assert.contains(cmd_str, "--dir /tmp/downloads")
		assert.contains(cmd_str, "14273")
	end)
end)
