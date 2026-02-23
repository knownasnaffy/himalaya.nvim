-- Keybindings for himalaya-envelope-listing buffer
local bufnr = vim.api.nvim_get_current_buf()

-- Close window
vim.keymap.set("n", "gq", function()
  require("himalaya").close()
end, { buffer = bufnr, desc = "Close Himalaya" })

-- Next folder (supports count)
vim.keymap.set("n", "]f", function()
  local count = vim.v.count1
  for _ = 1, count do
    require("himalaya.folder").next()
  end
end, { buffer = bufnr, desc = "Next folder" })

-- Previous folder (supports count)
vim.keymap.set("n", "[f", function()
  local count = vim.v.count1
  for _ = 1, count do
    require("himalaya.folder").previous()
  end
end, { buffer = bufnr, desc = "Previous folder" })

-- Folder picker
vim.keymap.set("n", "gF", function()
  require("himalaya.folder").picker()
end, { buffer = bufnr, desc = "Folder picker" })

-- Reload emails
vim.keymap.set("n", "gr", function()
  require("himalaya.folder").reload()
end, { buffer = bufnr, desc = "Reload emails" })
