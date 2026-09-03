local cli = require("himalaya.cli")

local M = {}

local function build_flag_cmd(subcommand, opts)
	opts = opts or {}
	local args = { "flag", subcommand }

	local mailbox = opts.mailbox or opts.folder
	if mailbox and mailbox ~= "" then
		table.insert(args, "-m")
		table.insert(args, mailbox)
	end

	local flags = type(opts.flags) == "table" and opts.flags or { opts.flag }
	for _, f in ipairs(flags) do
		if f and f ~= "" then
			table.insert(args, "-f")
			table.insert(args, f)
		end
	end

	local ids = type(opts.ids) == "table" and opts.ids or { opts.id }
	for _, id in ipairs(ids) do
		if id and id ~= "" then
			table.insert(args, tostring(id))
		end
	end

	return args
end

function M.add(opts, callback)
	local args = build_flag_cmd("add", opts)
	cli.run(args, callback, { account = opts.account })
end

function M.remove(opts, callback)
	local args = build_flag_cmd("remove", opts)
	cli.run(args, callback, { account = opts.account })
end

function M.set(opts, callback)
	local args = build_flag_cmd("set", opts)
	cli.run(args, callback, { account = opts.account })
end

return M
