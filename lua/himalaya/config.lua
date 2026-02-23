local M = {}

M.config = {
  sidebar = {
    width = 30,
  },
  split_ratio = 0.4, -- email list takes 40% when split
  wrap_folder_navigation = true, -- wrap to first/last when navigating folders
  icons_enabled = false, -- use nerd font icons for folders
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
