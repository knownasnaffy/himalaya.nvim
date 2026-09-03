local cli = require("himalaya.cli")

local M = {}

function M.list(opts, callback)
	opts = opts or {}
	local args = { "mailbox", "list" }

	cli.run_json(args, function(err, data)
		if err then
			callback(err, nil)
			return
		end

		local mailboxes = {}
		if data and type(data.mailboxes) == "table" then
			mailboxes = data.mailboxes
		elseif type(data) == "table" and #data > 0 then
			mailboxes = data
		end

		callback(nil, mailboxes)
	end, { account = opts.account })
end

return M
