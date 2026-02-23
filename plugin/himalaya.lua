vim.api.nvim_create_user_command("Himalaya", function()
  require("himalaya").open()
end, {})

vim.api.nvim_create_user_command("HimalayaFolder", function(opts)
  local arg = opts.args
  local folder_nav = require("himalaya.folder")
  
  if arg == "next" then
    folder_nav.next()
  elseif arg == "previous" then
    folder_nav.previous()
  else
    folder_nav.switch_to(arg)
  end
end, {
  nargs = 1,
  complete = function(arg_lead, cmd_line, cursor_pos)
    local state = require("himalaya.state")
    local completions = { "next", "previous" }
    vim.list_extend(completions, state.folder_list)
    return vim.tbl_filter(function(item)
      return vim.startswith(item, arg_lead)
    end, completions)
  end,
})

vim.api.nvim_create_user_command("HimalayaFolders", function()
  require("himalaya.folder").picker()
end, {})
