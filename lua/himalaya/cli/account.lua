local cli = require("himalaya.cli")

local M = {}

function M.list(opts, callback)
	opts = opts or {}
	local args = { "account", "list" }

	cli.run_json(args, function(err, data)
		if err then
			callback(err, nil)
			return
		end

		local accounts = {}
		if data and type(data.accounts) == "table" then
			accounts = data.accounts
		elseif type(data) == "table" and #data > 0 then
			accounts = data
		end

		callback(nil, accounts)
	end, opts)
end

function M.check(opts, callback)
	opts = opts or {}
	local args = { "account", "check" }
	cli.run_json(args, callback, opts)
end

return M
