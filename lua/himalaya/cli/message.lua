local cli = require("himalaya.cli")

local M = {}

function M.read(opts, callback)
	opts = opts or {}
	if not opts.id or opts.id == "" then
		callback("Message ID is required for read", nil)
		return
	end

	local args = { "message", "read" }

	local mailbox = opts.mailbox or opts.folder
	if mailbox and mailbox ~= "" then
		table.insert(args, "-m")
		table.insert(args, mailbox)
	end

	if opts.seen then
		table.insert(args, "--seen")
	end

	if opts.raw then
		table.insert(args, "--raw")
	end

	table.insert(args, tostring(opts.id))

	if opts.json then
		cli.run_json(args, callback, { account = opts.account })
	else
		cli.run(args, callback, { account = opts.account })
	end
end

function M.compose(opts, callback)
	opts = opts or {}
	local args = { "message", "compose" }

	if opts.to then
		if type(opts.to) == "table" then
			for _, t in ipairs(opts.to) do
				table.insert(args, "-t")
				table.insert(args, t)
			end
		else
			table.insert(args, "-t")
			table.insert(args, opts.to)
		end
	end

	if opts.cc then
		table.insert(args, "--cc")
		table.insert(args, opts.cc)
	end

	if opts.bcc then
		table.insert(args, "--bcc")
		table.insert(args, opts.bcc)
	end

	if opts.subject then
		table.insert(args, "-s")
		table.insert(args, opts.subject)
	end

	if opts.body then
		table.insert(args, "--body")
		table.insert(args, opts.body)
	end

	if opts.save then
		table.insert(args, "--save")
		table.insert(args, opts.save)
	end

	if opts.send then
		table.insert(args, "--send")
	end

	cli.run(args, callback, { account = opts.account, stdin = opts.stdin })
end

function M.reply(opts, callback)
	opts = opts or {}
	if not opts.id then
		callback("Message ID is required for reply", nil)
		return
	end

	local args = { "message", "reply" }

	local mailbox = opts.mailbox or opts.folder
	if mailbox and mailbox ~= "" then
		table.insert(args, "-m")
		table.insert(args, mailbox)
	end

	if opts.posting_style then
		table.insert(args, "-P")
		table.insert(args, opts.posting_style)
	end

	if opts.subject then
		table.insert(args, "-s")
		table.insert(args, opts.subject)
	end

	if opts.body then
		table.insert(args, "--body")
		table.insert(args, opts.body)
	end

	if opts.save then
		table.insert(args, "--save")
		table.insert(args, opts.save)
	end

	if opts.send then
		table.insert(args, "--send")
	end

	table.insert(args, tostring(opts.id))

	cli.run(args, callback, { account = opts.account, stdin = opts.stdin })
end

function M.forward(opts, callback)
	opts = opts or {}
	if not opts.id then
		callback("Message ID is required for forward", nil)
		return
	end

	local args = { "message", "forward" }

	local mailbox = opts.mailbox or opts.folder
	if mailbox and mailbox ~= "" then
		table.insert(args, "-m")
		table.insert(args, mailbox)
	end

	if opts.to then
		table.insert(args, "-t")
		table.insert(args, opts.to)
	end

	if opts.subject then
		table.insert(args, "-s")
		table.insert(args, opts.subject)
	end

	if opts.body then
		table.insert(args, "--body")
		table.insert(args, opts.body)
	end

	if opts.save then
		table.insert(args, "--save")
		table.insert(args, opts.save)
	end

	if opts.send then
		table.insert(args, "--send")
	end

	table.insert(args, tostring(opts.id))

	cli.run(args, callback, { account = opts.account, stdin = opts.stdin })
end

function M.send(opts, callback)
	opts = opts or {}
	local args = { "message", "send" }

	if opts.save then
		table.insert(args, "--save")
		table.insert(args, opts.save)
	end

	cli.run(args, callback, { account = opts.account, stdin = opts.message })
end

function M.add(opts, callback)
	opts = opts or {}
	local args = { "message", "add" }

	local mailbox = opts.mailbox or opts.folder or "Drafts"
	table.insert(args, "-m")
	table.insert(args, mailbox)

	if opts.flag then
		table.insert(args, "-f")
		table.insert(args, opts.flag)
	end

	if opts.send then
		table.insert(args, "--send")
	end

	cli.run(args, callback, { account = opts.account, stdin = opts.message })
end

function M.copy(opts, callback)
	opts = opts or {}
	local args = { "message", "copy" }

	if opts.from then
		table.insert(args, "-f")
		table.insert(args, opts.from)
	end

	if opts.to then
		table.insert(args, "-t")
		table.insert(args, opts.to)
	end

	local ids = type(opts.ids) == "table" and opts.ids or { opts.id }
	for _, id in ipairs(ids) do
		table.insert(args, tostring(id))
	end

	cli.run(args, callback, { account = opts.account })
end

function M.move(opts, callback)
	opts = opts or {}
	local args = { "message", "move" }

	if opts.from then
		table.insert(args, "-f")
		table.insert(args, opts.from)
	end

	if opts.to then
		table.insert(args, "-t")
		table.insert(args, opts.to)
	end

	local ids = type(opts.ids) == "table" and opts.ids or { opts.id }
	for _, id in ipairs(ids) do
		table.insert(args, tostring(id))
	end

	cli.run(args, callback, { account = opts.account })
end

function M.delete(opts, callback)
	opts = opts or {}
	local args = { "message", "delete" }

	local mailbox = opts.mailbox or opts.folder
	if mailbox and mailbox ~= "" then
		table.insert(args, "-m")
		table.insert(args, mailbox)
	end

	local ids = type(opts.ids) == "table" and opts.ids or { opts.id }
	for _, id in ipairs(ids) do
		table.insert(args, tostring(id))
	end

	cli.run(args, callback, { account = opts.account })
end

return M
