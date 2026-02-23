local state = require("himalaya.state")
local config = require("himalaya.config")
local folder_cli = require("himalaya.cli.folder")
local folder_list = require("himalaya.ui.folder_list")
local envelope = require("himalaya.cli.envelope")
local envelope_list = require("himalaya.ui.envelope_list")

local M = {}

-- Reload emails for current folder
local function reload_emails()
  if not state.main then
    return
  end
  
  local height = vim.api.nvim_win_get_height(vim.api.nvim_get_current_win())
  envelope.list({ folder = state.current_folder, page_size = height }, function(err, data)
    if err then
      vim.notify("Failed to load emails: " .. err, vim.log.levels.ERROR)
      return
    end
    
    envelope_list.render(state.main, data)
  end)
end

-- Reload folder list to update highlighting
local function reload_folders()
  if not state.sidebar then
    return
  end
  
  folder_cli.list({}, function(err, data)
    if err then
      vim.notify("Failed to reload folders: " .. err, vim.log.levels.ERROR)
      return
    end
    
    folder_list.render(state.sidebar, data)
  end)
end

-- Switch to a folder by name
function M.switch_to(folder_name)
  if not vim.tbl_contains(state.folder_list, folder_name) then
    vim.notify("Folder not found: " .. folder_name, vim.log.levels.ERROR)
    return
  end
  
  state.current_folder = folder_name
  reload_folders()
  reload_emails()
end

-- Navigate to next folder
function M.next()
  if #state.folder_list == 0 then
    return
  end
  
  local current_idx = nil
  for i, name in ipairs(state.folder_list) do
    if name == state.current_folder then
      current_idx = i
      break
    end
  end
  
  if not current_idx then
    state.current_folder = state.folder_list[1]
  else
    local next_idx = current_idx + 1
    if next_idx > #state.folder_list then
      if config.config.wrap_folder_navigation then
        next_idx = 1
      else
        vim.notify("Already at last folder", vim.log.levels.WARN)
        return
      end
    end
    state.current_folder = state.folder_list[next_idx]
  end
  
  reload_folders()
  reload_emails()
end

-- Navigate to previous folder
function M.previous()
  if #state.folder_list == 0 then
    return
  end
  
  local current_idx = nil
  for i, name in ipairs(state.folder_list) do
    if name == state.current_folder then
      current_idx = i
      break
    end
  end
  
  if not current_idx then
    state.current_folder = state.folder_list[1]
  else
    local prev_idx = current_idx - 1
    if prev_idx < 1 then
      if config.config.wrap_folder_navigation then
        prev_idx = #state.folder_list
      else
        vim.notify("Already at first folder", vim.log.levels.WARN)
        return
      end
    end
    state.current_folder = state.folder_list[prev_idx]
  end
  
  reload_folders()
  reload_emails()
end

-- Show folder picker
function M.picker()
  if #state.folder_list == 0 then
    vim.notify("No folders available", vim.log.levels.WARN)
    return
  end
  
  vim.ui.select(state.folder_list, {
    prompt = "Select folder:",
  }, function(choice)
    if choice then
      M.switch_to(choice)
    end
  end)
end

return M
