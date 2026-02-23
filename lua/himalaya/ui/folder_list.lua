local NuiLine = require("nui.line")
local folder_utils = require("himalaya.utils.folder")
local state = require("himalaya.state")
local config = require("himalaya.config")

local M = {}

-- Recursively render folder tree
local function render_tree(items, lines, depth)
  depth = depth or 0
  
  for _, item in ipairs(items) do
    local line = NuiLine()
    local indent = string.rep("  ", depth)
    
    -- Highlight active folder
    local hl_group = "HimalayaFolder"
    if item.name and item.name == state.current_folder then
      hl_group = "HimalayaFolderActive"
    end
    
    -- Folder icon
    local icon = ""
    if config.config.icons_enabled then
      -- Use nerd font icons:  for folders with children,  for leaf folders
      icon = (#item.children > 0) and " " or " "
    end
    
    -- Add space after icon if present
    local display = icon ~= "" and (icon .. " " .. item.displayName) or item.displayName
    line:append(indent .. display, hl_group)
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
  
  -- Store flat list of accessible folders in state
  state.folder_list = folder_utils.get_accessible_folders(tree)
  
  -- Clear buffer first
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  
  local lines = {}
  render_tree(tree, lines)
  
  for i, line in ipairs(lines) do
    line:render(bufnr, -1, i)
  end
  
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false
end

return M
