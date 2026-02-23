local M = {}

M.executable = "himalaya"

function M.run(args, callback)
  local cmd = { "sh", "-c", "RUST_LOG=off " .. M.executable .. " " .. table.concat(args, " ") }
  
  local stdout = {}
  local stderr = {}
  
  vim.fn.jobstart(cmd, {
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
        local error = table.concat(stderr, "\n")
        callback(error, nil)
      end
    end,
  })
end

function M.run_json(args, callback)
  M.run(args, function(err, output)
    if err then
      callback(err, nil)
      return
    end
    
    -- Handle empty output
    if not output or output == "" then
      callback(nil, {})
      return
    end
    
    local ok, data = pcall(vim.json.decode, output)
    if not ok then
      callback("Failed to parse JSON: " .. data, nil)
      return
    end
    
    -- Convert vim.NIL to nil recursively
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
  end)
end

return M
