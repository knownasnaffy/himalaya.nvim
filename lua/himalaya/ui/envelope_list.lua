local NuiLine = require("nui.line")
local date_utils = require("himalaya.utils.date")

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
    line:append(string.format("%-25s ", from:sub(1, 25)), "HimalayaFrom")
    
    -- Subject
    local subject = env.subject or "(no subject)"
    local max_subject_len = 60
    local subject_display = subject:sub(1, max_subject_len)
    if #subject > max_subject_len then
      subject_display = subject_display .. "..."
    end
    line:append(string.format("%-63s ", subject_display), "HimalayaSubject")
    
    -- Date (relative)
    local relative = date_utils.relative_date(env.date)
    line:append("(" .. relative .. ")", "HimalayaDate")
    
    table.insert(lines, line)
  end
  
  for i, line in ipairs(lines) do
    line:render(bufnr, -1, i)
  end
  
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false
end

return M
