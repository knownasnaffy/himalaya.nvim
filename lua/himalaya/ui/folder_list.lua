local NuiLine = require("nui.line")

local M = {}

function M.render(bufnr, folders)
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].filetype = "himalaya-folder-listing"
  
  local lines = {}
  
  for _, folder in ipairs(folders) do
    local line = NuiLine()
    
    -- Simple folder display (no tree for now)
    local name = folder.name
    
    -- Indent subfolders
    local indent = ""
    local depth = select(2, name:gsub("/", ""))
    if depth > 0 then
      indent = string.rep("  ", depth)
      name = name:match("([^/]+)$") or name
    end
    
    line:append(indent .. "📁 " .. name, "HimalayaFolder")
    table.insert(lines, line)
  end
  
  for i, line in ipairs(lines) do
    line:render(bufnr, -1, i)
  end
  
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false
end

return M
