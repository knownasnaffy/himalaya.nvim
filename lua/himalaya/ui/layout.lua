local Layout = require("nui.layout")
local Popup = require("nui.popup")
local state = require("himalaya.state")
local config = require("himalaya.config")
local envelope = require("himalaya.cli.envelope")
local folder = require("himalaya.cli.folder")
local envelope_list = require("himalaya.ui.envelope_list")
local folder_list = require("himalaya.ui.folder_list")

local M = {}

function M.create()
  local sidebar = Popup({
    enter = false,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = " Folders ",
        top_align = "center",
      },
    },
  })

  local main = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = " Emails ",
        top_align = "center",
      },
    },
  })

  local layout = Layout(
    {
      position = "50%",
      size = {
        width = "90%",
        height = "90%",
      },
    },
    Layout.Box({
      Layout.Box(sidebar, { size = config.config.sidebar.width }),
      Layout.Box(main, { grow = 1 }),
    }, { dir = "row" })
  )

  -- Set filetype for sidebar
  vim.bo[sidebar.bufnr].filetype = "himalaya-folder-listing"
  
  -- Load folders
  folder.list({}, function(err, data)
    if err then
      vim.notify("Failed to load folders: " .. err, vim.log.levels.ERROR)
      return
    end
    
    folder_list.render(sidebar.bufnr, data)
  end)
  
  -- Load envelopes
  envelope.list({ page_size = 50 }, function(err, data)
    if err then
      vim.notify("Failed to load emails: " .. err, vim.log.levels.ERROR)
      return
    end
    
    envelope_list.render(main.bufnr, data)
  end)

  state.layout = layout
  state.sidebar = sidebar
  state.main = main
  
  return layout
end

return M
