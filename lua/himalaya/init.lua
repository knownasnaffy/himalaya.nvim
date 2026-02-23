local config = require("himalaya.config")
local layout = require("himalaya.ui.layout")

local M = {}

function M.setup(opts)
  config.setup(opts)
end

function M.open()
  local l = layout.create()
  l:mount()
end

return M
