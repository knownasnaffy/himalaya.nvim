local NuiLine = require("nui.line")
local folder_utils = require("himalaya.utils.folder")

local M = {}

-- Recursively render folder tree
local function render_tree(items, lines, depth)
  depth = depth or 0
  
  for _, item in ipairs(items) do
    local line = NuiLine()
    local indent = string.rep("  ", depth)
    
    -- Folder icon and name
    line:append(indent .. "📁 " .. item.displayName, "HimalayaFolder")
    table.insert(lines, line)
    
    -- Render children recursively
    if #item.children > 0 then
      render_tree(item.children, lines, depth + 1)
    end
  end
end

function M.render(bufnr, folders)
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].filetype = "himalaya-folder-listing"
  
  -- Parse folders into tree structure
  local tree = folder_utils.parse_folders(folders)
  
  local lines = {}
  render_tree(tree, lines)
  
  for i, line in ipairs(lines) do
    line:render(bufnr, -1, i)
  end
  
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false
end

return M
