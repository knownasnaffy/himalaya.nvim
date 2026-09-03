local cli = require("himalaya.cli")

local M = {}

local function build_envelope_args(subcommand, opts)
	opts = opts or {}
	local args = { "envelope", subcommand }

	local mailbox = opts.mailbox or opts.folder
	if mailbox and mailbox ~= "" then
		table.insert(args, "-m")
		table.insert(args, mailbox)
	end

	if opts.page then
		table.insert(args, "-p")
		table.insert(args, tostring(opts.page))
	end

	if opts.page_size then
		table.insert(args, "-s")
		table.insert(args, tostring(opts.page_size))
	end

	if opts.max_width then
		table.insert(args, "-w")
		table.insert(args, tostring(opts.max_width))
	end

	if opts.recipient then
		table.insert(args, "-r")
	end

	if opts.has_attachment then
		table.insert(args, "--has-attachment")
	end

	if opts.query and opts.query ~= "" then
		table.insert(args, opts.query)
	end

	return args
end

function M.list(opts, callback)
	opts = opts or {}
	local args = build_envelope_args("list", opts)

	cli.run_json(args, function(err, data)
		if err then
			callback(err, nil)
			return
		end

		local envelopes = {}
		if data and type(data.envelopes) == "table" then
			envelopes = data.envelopes
		elseif type(data) == "table" and #data > 0 then
			envelopes = data
		end

		callback(nil, envelopes)
	end, { account = opts.account })
end

function M.search(opts, callback)
	opts = opts or {}
	local args = build_envelope_args("search", opts)

	cli.run_json(args, function(err, data)
		if err then
			callback(err, nil)
			return
		end

		local envelopes = {}
		if data and type(data.envelopes) == "table" then
			envelopes = data.envelopes
		elseif type(data) == "table" and #data > 0 then
			envelopes = data
		end

		callback(nil, envelopes)
	end, { account = opts.account })
end

return M
