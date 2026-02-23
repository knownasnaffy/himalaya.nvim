local NuiLine = require("nui.line")
local date_utils = require("himalaya.utils.date")

local M = {}

function M.render(bufnr, envelopes)
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].filetype = "himalaya-envelope-listing"
  
  -- Use fixed max date width
  local max_date_width = date_utils.max_date_width()
  
  -- Get buffer width for subject calculation
  local bufwidth = vim.api.nvim_win_get_width(0)
  local subject_width = bufwidth - 2 - 25 - max_date_width - 6 -- flag + from + date + spacing + parens
  
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
    
    -- Subject - truncate based on display width
    local subject = env.subject or "(no subject)"
    local subject_display = subject
    
    -- Truncate to fit display width
    while vim.fn.strdisplaywidth(subject_display) > subject_width do
      subject_display = subject_display:sub(1, #subject_display - 1)
    end
    
    if vim.fn.strdisplaywidth(subject) > subject_width then
      subject_display = subject_display .. "..."
    end
    
    -- Pad subject to fixed width
    local padding = subject_width + 3 - vim.fn.strdisplaywidth(subject_display)
    line:append(subject_display .. string.rep(" ", padding), "HimalayaSubject")
    
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
