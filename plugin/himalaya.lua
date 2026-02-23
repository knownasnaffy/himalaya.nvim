vim.api.nvim_create_user_command("Himalaya", function()
  require("himalaya").open()
end, {})
