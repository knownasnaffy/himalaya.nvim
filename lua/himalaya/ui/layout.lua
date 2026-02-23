local Layout = require("nui.layout")
local Popup = require("nui.popup")
local state = require("himalaya.state")
local config = require("himalaya.config")

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

  state.layout = layout
  return layout
end

return M
