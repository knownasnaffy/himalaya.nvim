local cli = require("himalaya.cli")

local M = {}

function M.list(opts, callback)
	opts = opts or {}
	if not opts.id then
		callback("Message ID is required for attachment list", nil)
		return
	end

	local args = { "attachment", "list" }

	local mailbox = opts.mailbox or opts.folder
	if mailbox and mailbox ~= "" then
		table.insert(args, "-m")
		table.insert(args, mailbox)
	end

	if opts.inline then
		table.insert(args, "--inline")
	end

	table.insert(args, tostring(opts.id))

	cli.run_json(args, function(err, data)
		if err then
			callback(err, nil)
			return
		end

		local attachments = {}
		if data and type(data.attachments) == "table" then
			attachments = data.attachments
		elseif type(data) == "table" then
			attachments = data
		end

		callback(nil, attachments)
	end, { account = opts.account })
end

function M.download(opts, callback)
	opts = opts or {}
	if not opts.id then
		callback("Message ID is required for attachment download", nil)
		return
	end

	local args = { "attachment", "download" }

	local mailbox = opts.mailbox or opts.folder
	if mailbox and mailbox ~= "" then
		table.insert(args, "-m")
		table.insert(args, mailbox)
	end

	if opts.dir and opts.dir ~= "" then
		table.insert(args, "--dir")
		table.insert(args, opts.dir)
	end

	table.insert(args, tostring(opts.id))

	local attachment_ids = type(opts.attachment_ids) == "table" and opts.attachment_ids
		or (opts.attachment_id and { opts.attachment_id } or {})
	for _, att_id in ipairs(attachment_ids) do
		table.insert(args, tostring(att_id))
	end

	cli.run(args, callback, { account = opts.account })
end

return M
