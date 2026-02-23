local cli = require("himalaya.cli")

local M = {}

function M.list(opts, callback)
	opts = opts or {}
	local args = { "--output json", "envelope list" }

	if opts.folder then
		table.insert(args, "--folder")
		table.insert(args, vim.fn.shellescape(opts.folder))
	end

	if opts.account and opts.account ~= "" then
		table.insert(args, "--account")
		table.insert(args, vim.fn.shellescape(opts.account))
	end

	if opts.page_size then
		table.insert(args, "--page-size")
		table.insert(args, tostring(opts.page_size))
	end

	if opts.page then
		table.insert(args, "--page")
		table.insert(args, tostring(opts.page))
	end

	cli.run_json(args, callback)
end

return M
