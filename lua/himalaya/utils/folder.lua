local M = {}

-- Parse folders into a tree structure
function M.parse_folders(folders)
  local root = {}
  local lookup = {} -- Quick lookup by display name path
  
  for _, folder in ipairs(folders) do
    local parts = vim.split(folder.name, "/", { plain = true })
    local current_path = ""
    local parent = root
    
    for i, part in ipairs(parts) do
      local is_last = (i == #parts)
      
      if current_path == "" then
        current_path = part
      else
        current_path = current_path .. "/" .. part
      end
      
      -- Check if this part already exists in current level
      local existing = nil
      for _, item in ipairs(parent) do
        if item.displayName == part then
          existing = item
          break
        end
      end
      
      if not existing then
        -- Create new item
        local item = {
          displayName = part,
          children = {},
        }
        
        -- Only add 'name' field if this is the last part (accessible folder)
        if is_last then
          item.name = folder.name
        end
        
        table.insert(parent, item)
        lookup[current_path] = item
        parent = item.children
      else
        -- Item exists, navigate into it
        -- If this is the last part and item doesn't have name, add it
        if is_last and not existing.name then
          existing.name = folder.name
        end
        parent = existing.children
      end
    end
  end
  
  return root
end

return M
