local NuiLine = require("nui.line")

local M = {}

function M.render(bufnr, envelopes)
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].filetype = "himalaya-envelope-listing"
  
  local lines = {}
  
  for _, env in ipairs(envelopes) do
    local line = NuiLine()
    
    -- Flag indicator
    local flag = " "
    if vim.tbl_contains(env.flags or {}, "Seen") then
      flag = " "
    else
      flag = "●"
    end
    line:append(flag .. " ", "HimalayaFlag")
    
    -- From
    local from = env.from.name or env.from.addr or "Unknown"
    line:append(string.format("%-20s ", from:sub(1, 20)), "HimalayaFrom")
    
    -- Subject
    local subject = env.subject or "(no subject)"
    line:append(subject, "HimalayaSubject")
    
    table.insert(lines, line)
  end
  
  for i, line in ipairs(lines) do
    line:render(bufnr, -1, i)
  end
  
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false
end

return M
