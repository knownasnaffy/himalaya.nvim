-- Highlight groups for himalaya.nvim
-- Don't set bg so cursorline shows through
vim.api.nvim_set_hl(0, "HimalayaFlag", { fg = vim.api.nvim_get_hl(0, { name = "Special" }).fg })
vim.api.nvim_set_hl(0, "HimalayaFrom", { fg = vim.api.nvim_get_hl(0, { name = "Identifier" }).fg })
vim.api.nvim_set_hl(0, "HimalayaSubject", { fg = vim.api.nvim_get_hl(0, { name = "Normal" }).fg })
vim.api.nvim_set_hl(0, "HimalayaDate", { fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg })
vim.api.nvim_set_hl(0, "HimalayaFolder", { fg = vim.api.nvim_get_hl(0, { name = "Directory" }).fg })

-- Active folder uses CursorLine background
local cursorline_hl = vim.api.nvim_get_hl(0, { name = "CursorLine" })
local directory_hl = vim.api.nvim_get_hl(0, { name = "Directory" })
vim.api.nvim_set_hl(0, "HimalayaFolderActive", { 
  fg = directory_hl.fg,
  bg = cursorline_hl.bg,
  bold = true,
})
