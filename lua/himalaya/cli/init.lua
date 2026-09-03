local runner = require("himalaya.cli.runner")

local M = {}

M.executable = "himalaya"
M.config_path = nil

function M.build_cmd(args, opts)
	opts = opts or {}
	local cmd = { M.executable }

	if opts.json then
		table.insert(cmd, "--json")
	end

	table.insert(cmd, "--log-level")
	table.insert(cmd, "off")

	local config = opts.config or M.config_path
	if config and config ~= "" then
		table.insert(cmd, "--config")
		table.insert(cmd, config)
	end

	local account = opts.account
	if account and account ~= "" then
		table.insert(cmd, "--account")
		table.insert(cmd, account)
	end

	if opts.backend and opts.backend ~= "" then
		table.insert(cmd, "--backend")
		table.insert(cmd, opts.backend)
	end

	for _, arg in ipairs(args) do
		table.insert(cmd, arg)
	end

	return cmd
end

function M.run(args, callback, opts)
	opts = opts or {}
	local cmd = M.build_cmd(args, opts)
	runner.run(cmd, callback, opts)
end

function M.run_json(args, callback, opts)
	opts = opts or {}
	opts.json = true

	M.run(args, function(err, output)
		if err then
			callback(err, nil)
			return
		end

		if not output or output == "" or (type(output) == "string" and output:match("^%s*$")) then
			callback(nil, {})
			return
		end

		local data
		if type(output) == "table" then
			data = output
		else
			local ok, res = pcall(vim.json.decode, output)
			if not ok then
				callback("Failed to parse JSON: " .. tostring(res) .. "\nOutput was: " .. tostring(output), nil)
				return
			end
			data = res
		end

		local function clean_nil(obj)
			if type(obj) == "table" then
				for k, v in pairs(obj) do
					if v == vim.NIL then
						obj[k] = nil
					elseif type(v) == "table" then
						clean_nil(v)
					end
				end
			end
			return obj
		end

		data = clean_nil(data)
		callback(nil, data)
	end, opts)
end

return M
