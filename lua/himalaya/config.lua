local M = {}

M.config = {
  sidebar = {
    width = 30,
  },
  split_ratio = 0.4, -- email list takes 40% when split
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
