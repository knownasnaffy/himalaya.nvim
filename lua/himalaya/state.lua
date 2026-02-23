local M = {}

M.current_account = ""
M.current_folder = "INBOX"
M.layout = nil
M.sidebar = nil
M.main = nil
M.is_open = false
M.folder_list = {} -- Flat list of accessible folders (with name field)

return M
