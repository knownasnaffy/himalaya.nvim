local M = {}

local mock_runner = nil

function M.set_mock(fn)
	mock_runner = fn
end

function M.reset_mock()
	mock_runner = nil
end

function M.run(cmd, callback, opts)
	opts = opts or {}

	if mock_runner then
		mock_runner(cmd, callback, opts)
		return
	end

	local stdout = {}
	local stderr = {}

	local job_opts = {
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data then
				vim.list_extend(stdout, data)
			end
		end,
		on_stderr = function(_, data)
			if data then
				vim.list_extend(stderr, data)
			end
		end,
		on_exit = function(_, code)
			if code == 0 then
				local output = table.concat(stdout, "\n")
				callback(nil, output)
			else
				local err_msg = table.concat(stderr, "\n")
				if err_msg == "" then
					err_msg = string.format("Process exited with code %d", code)
				end
				callback(err_msg, nil)
			end
		end,
	}

	local job_id = vim.fn.jobstart(cmd, job_opts)
	if job_id <= 0 then
		callback("Failed to start job: " .. vim.inspect(cmd), nil)
		return
	end

	if opts.stdin then
		vim.fn.chansend(job_id, opts.stdin)
		vim.fn.chanclose(job_id, "stdin")
	end
end

return M
