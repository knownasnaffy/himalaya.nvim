local cli = require("himalaya.cli")

local M = {}

function M.list(opts, callback)
	opts = opts or {}
	local args = { "--output json", "folder list" }

	if opts.account and opts.account ~= "" then
		table.insert(args, "--account")
		table.insert(args, opts.account)
	end

	cli.run_json(args, callback)
end

return M
